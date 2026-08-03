import { describe, it, expect, vi } from 'vitest';
import HillGoApi from '../js/api.js';

const { resolveApiBase, hgApi, hgApiWithRetry, HgHttpError, HgNetworkError } = HillGoApi;

function mockResponse(ok, status, body) {
  return { ok, status, json: async () => body };
}

describe('resolveApiBase', () => {
  it('prefers an explicitly configured HILLGO_API_BASE', () => {
    const win = { HILLGO_API_BASE: 'https://api.hillgo.com', location: { hostname: 'hillgo.com' } };
    expect(resolveApiBase(win)).toBe('https://api.hillgo.com');
  });

  it('falls back to the local dev API only on localhost', () => {
    const win = { HILLGO_API_BASE: '', location: { hostname: 'localhost' } };
    expect(resolveApiBase(win)).toBe('http://127.0.0.1:8000/api');
  });

  it('falls back to the local dev API on 127.0.0.1', () => {
    const win = { HILLGO_API_BASE: '', location: { hostname: '127.0.0.1' } };
    expect(resolveApiBase(win)).toBe('http://127.0.0.1:8000/api');
  });

  it('returns an empty string for an unconfigured non-local deployment (no silent 127.0.0.1 fallback)', () => {
    const win = { HILLGO_API_BASE: '', location: { hostname: 'hillgo.com' } };
    expect(resolveApiBase(win)).toBe('');
  });
});

describe('hgApi', () => {
  it('throws HgNetworkError when no API base is configured', async () => {
    await expect(hgApi('', 'GET', '/public/track/1')).rejects.toBeInstanceOf(HgNetworkError);
  });

  it('throws HgNetworkError when the underlying fetch rejects (offline / DNS / CORS)', async () => {
    const failingFetch = vi.fn().mockRejectedValue(new TypeError('Failed to fetch'));
    await expect(
      hgApi('http://127.0.0.1:8000/api', 'GET', '/public/track/1', undefined, failingFetch)
    ).rejects.toBeInstanceOf(HgNetworkError);
  });

  it('throws HgHttpError with the server message on a non-2xx response', async () => {
    const fetchImpl = vi.fn().mockResolvedValue(mockResponse(false, 422, { message: 'Tracking number not found.' }));
    await expect(
      hgApi('http://127.0.0.1:8000/api', 'GET', '/public/track/BAD', undefined, fetchImpl)
    ).rejects.toMatchObject({ name: 'HgHttpError', message: 'Tracking number not found.', status: 422 });
  });

  it('joins Laravel-style validation `errors` into the HgHttpError message', async () => {
    const fetchImpl = vi
      .fn()
      .mockResolvedValue(mockResponse(false, 422, { errors: { email: ['The email field is required.'] } }));
    await expect(
      hgApi('http://127.0.0.1:8000/api', 'POST', '/public/newsletter', { email: '' }, fetchImpl)
    ).rejects.toMatchObject({ message: 'The email field is required.' });
  });

  it('resolves with the parsed JSON body on success', async () => {
    const fetchImpl = vi.fn().mockResolvedValue(mockResponse(true, 200, { quote: { fare: 120 } }));
    const result = await hgApi('http://127.0.0.1:8000/api', 'POST', '/public/quotes', { origin: 'A', destination: 'B' }, fetchImpl);
    expect(result).toEqual({ quote: { fare: 120 } });
  });
});

describe('hgApiWithRetry', () => {
  const noopSleep = () => Promise.resolve();

  it('retries on network failures and succeeds once the connection recovers', async () => {
    const fetchImpl = vi
      .fn()
      .mockRejectedValueOnce(new TypeError('Failed to fetch'))
      .mockResolvedValueOnce(mockResponse(true, 200, { already: false }));

    const result = await hgApiWithRetry(
      'http://127.0.0.1:8000/api',
      'POST',
      '/public/newsletter',
      { email: 'a@b.com' },
      { fetchImpl, sleep: noopSleep }
    );

    expect(result).toEqual({ already: false });
    expect(fetchImpl).toHaveBeenCalledTimes(2);
  });

  it('gives up after 3 attempts on persistent network failure', async () => {
    const fetchImpl = vi.fn().mockRejectedValue(new TypeError('Failed to fetch'));

    await expect(
      hgApiWithRetry('http://127.0.0.1:8000/api', 'POST', '/public/contact', {}, { fetchImpl, sleep: noopSleep })
    ).rejects.toBeInstanceOf(HgNetworkError);
    expect(fetchImpl).toHaveBeenCalledTimes(3);
  });

  it('does NOT retry a server-rejected (HgHttpError) submission', async () => {
    const fetchImpl = vi.fn().mockResolvedValue(mockResponse(false, 422, { message: 'Invalid vehicle type.' }));

    await expect(
      hgApiWithRetry(
        'http://127.0.0.1:8000/api',
        'POST',
        '/public/partner-applications',
        {},
        { fetchImpl, sleep: noopSleep }
      )
    ).rejects.toBeInstanceOf(HgHttpError);
    expect(fetchImpl).toHaveBeenCalledTimes(1);
  });
});
