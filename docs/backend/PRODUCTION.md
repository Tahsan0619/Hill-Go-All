# HillGo — Production Runbook

Single Laravel + MySQL backend (`hillgo-backend/`) is the source of truth for:

| Surface | How to run (dev) | API base |
|---------|------------------|----------|
| Backend API | `cd hillgo-backend && php artisan serve` | `http://localhost:8000/api` |
| Admin Panel | `cd "Hill Go Admin Panel/ui" && php -S localhost:5500` | uses `http://localhost:8000/api` |
| Public Web | `cd "Hill Go Public Web" && php -S localhost:3000` | uses `http://localhost:8000/api` |
| Customer App | `flutter run --dart-define=HILLGO_API_BASE=http://<host>:8000/api` | same |
| Rider App | same | `/api/rider` |
| Merchant App | same | `/api/merchant` |
| Courier App | same | `/api/courier` |

On a physical device/emulator, replace `localhost` with your machine's LAN IP and add that origin to `CORS_ALLOWED_ORIGINS` if the Admin/Public web is also served from it.

---

## Production deploy checklist

1. **Server**
   - PHP 8.2+ with extensions: `mbstring`, `openssl`, `pdo_mysql`, `tokenizer`, `xml`, `ctype`, `json`, `bcmath`, `fileinfo`, `gd` (or imagick for uploads)
   - MySQL 8 / MariaDB 10.4+
   - Nginx/Apache pointing `public/` as the web root
   - HTTPS required (`SESSION_SECURE_COOKIE=true`)

2. **Environment**
   ```bash
   cp .env.production.example .env
   php artisan key:generate
   # Fill DB_*, APP_URL, CORS_ALLOWED_ORIGINS, SEED_ADMIN_PASSWORD, mail/SMS
   ```
   - `APP_ENV=production`
   - `APP_DEBUG=false` (never leave true in prod)
   - `CORS_ALLOWED_ORIGINS` = exact Admin + Public origins (no `*`)

3. **Database**
   ```bash
   php artisan migrate --force
   php artisan db:seed --force   # structural only: regions, pricing, one super_admin, settings
   ```
   Immediately log into Admin and change the seeded password.

4. **Optimize**
   ```bash
   php artisan config:cache
   php artisan route:cache
   php artisan event:cache
   php artisan storage:link   # only if you expose public disk assets
   ```
   KYC/document uploads stay on the **private** disk (`storage/app/private`) and are only served through admin-authenticated document routes.

5. **Queue / schedule (recommended)**
   - `QUEUE_CONNECTION=database` (or Redis) + a worker: `php artisan queue:work`
   - Cron: `* * * * * php /path/to/artisan schedule:run`
   - Offer expiry / requeue can be driven by rider poll + `Dispatch::requeue`; add a scheduled command if you want server-side expiry without client traffic.

6. **SMS / OTP**
   - Dev: OTPs are logged to `storage/logs/laravel.log`
   - Prod: wire a real SMS provider in `OtpService` (env keys in `.env.production.example`). Never return OTPs in API responses.

7. **Flutter release builds**
   ```bash
   flutter build apk --dart-define=HILLGO_API_BASE=https://api.<your-domain>/api
   flutter build appbundle --dart-define=HILLGO_API_BASE=https://api.<your-domain>/api
   ```
   Use the same define for iOS/IPA builds.

---

## Default ops credential (change immediately)

- Email: `admin@hillgo.app`
- Password: value of `SEED_ADMIN_PASSWORD` (dev default `HillGo@2026!`)

---

## Local demo logins (`SEED_DEMO_USERS=true`)

Seed with `php artisan db:seed --class=DemoUsersSeeder` (or full `db:seed` when the env flag is on).  
**Never enable in production.** Shared password: `HillGoDemo@2026!` (or `SEED_DEMO_PASSWORD`). Local demo OTP for phone login: `1234`.

| Surface | How to sign in |
|---------|----------------|
| Admin | `admin@hillgo.app` / `HillGo@2026!` |
| Customer | Email: `customer@demo.hillgo.app` / `HillGoDemo@2026!` — or phone `01710000001` + OTP `1234` |
| Rider | Phone `01710000002` + OTP `1234` (or API email `rider@demo.hillgo.app` / password) |
| Merchant | `merchant@demo.hillgo.app` / `HillGoDemo@2026!` |
| Courier | `courier@demo.hillgo.app` / `HillGoDemo@2026!` |

---

## Interconnect (how surfaces talk)

All six surfaces share one MySQL database. Examples:

- Customer books a ride → `rides` + `trips` offer → Rider sees offer → Admin rides/trips lists update → customer notification inbox updated.
- Merchant marks order ready → rider dispatch → customer order status advances.
- Courier verifies delivery OTP → parcel delivered → Admin parcel OTP log updated → courier balance credited.
- Admin closes a district (Region Lock) → register/book in that district returns 422 across apps.
- Admin wallet adjust → customer wallet balance/transactions update immediately.

There is **no localStorage / SharedPreferences business state**. Tokens are the only client-side session secret (Sanctum opaque personal access tokens, hashed at rest).

---

## Security baseline

- Role middleware (`role:`) on every authenticated route group; role comes from the DB, never the client body.
- BOLA: every resource query scoped to `request->user()` (or admin).
- Money math server-side only (`PricingService`, `Wallet`, locked DB transactions).
- Auth / OTP / public-write endpoints use named per-path rate limiters.
- Force-JSON middleware on the API stack (no HTML error pages for mobile clients).
- CORS allow-list only.
- See also: `BACKEND_PROGRESS.md` security checklist.
