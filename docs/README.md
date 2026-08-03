# HillGo Docs

Central documentation for the [Hill-Go-All](https://github.com/Tahsan0619/Hill-Go-All) monorepo.

The repository root keeps [`README.md`](../README.md) for GitHub landing, plus app/backend code folders and [`sql/`](../sql/) for database dumps. Project docs live here.

---

## Layout

| Folder | Contents |
|--------|----------|
| [`audits/technical/`](audits/technical/) | Full-platform technical audits (`AUDIT_*.md`) + combined `All-6-Files.md` |
| [`audits/frontend-security/`](audits/frontend-security/) | Frontend security audits and fix-result evidence |
| [`remediation/`](remediation/) | Platform remediation reports, summary, and `NEW_FINDINGS.md` |
| [`prompts/`](prompts/) | Authoring / implementation prompts (e.g. Laravel backend prompt) |
| [`backend/`](backend/) | Backend progress notes and production runbook |
| [`architecture/`](architecture/) | Platform architecture deliverables (PDF/DOCX) |
| [`admin/`](admin/) | Admin Panel design/stitch notes |

Database dumps (not under `docs/`): [`../sql/`](../sql/) — **latest:** [`../sql/HillGo-Last.sql`](../sql/HillGo-Last.sql).

---

## Quick links

### Audits
- [Customer App](audits/technical/AUDIT_CUSTOMER_APP.md)
- [Courier Agent App](audits/technical/AUDIT_COURIER_AGENT_APP.md)
- [Rider/Driver App](audits/technical/AUDIT_RIDER_DRIVER_APP.md)
- [Vendor/Merchant App](audits/technical/AUDIT_VENDOR_MERCHANT_APP.md)
- [Admin Panel](audits/technical/AUDIT_ADMIN_PANEL.md)
- [Public Web](audits/technical/AUDIT_PUBLIC_WEB.md)
- [All six audits (combined)](audits/technical/All-6-Files.md)
- [Frontend security audits](audits/frontend-security/README.md)

### Remediation
- [Platform summary](remediation/PLATFORM_REMEDIATION_SUMMARY.md)
- [New findings (out of checklist)](remediation/NEW_FINDINGS.md)
- [Customer](remediation/REMEDIATION_CUSTOMER_APP.md) · [Courier](remediation/REMEDIATION_COURIER_AGENT_APP.md) · [Rider](remediation/REMEDIATION_RIDER_DRIVER_APP.md) · [Vendor](remediation/REMEDIATION_VENDOR_MERCHANT_APP.md) · [Admin](remediation/REMEDIATION_ADMIN_PANEL.md) · [Public Web](remediation/REMEDIATION_PUBLIC_WEB.md) · [Backend](remediation/REMEDIATION_BACKEND.md)

### Backend & ops
- [Production runbook](backend/PRODUCTION.md)
- [Backend progress](backend/BACKEND_PROGRESS.md)
- [SQL dumps (latest: HillGo-Last.sql)](../sql/README.md)

### Prompts & architecture
- [Laravel backend prompt](prompts/LARAVEL_BACKEND_PROMPT.md)
- [Architecture PDF/DOCX](architecture/)
- [Admin Stitch screens notes](admin/STITCH_ADMIN_SCREENS.md)

---

## What stays with each app

Per-component `README.md`, `featurelist.md`, deploy notes (e.g. Public Web `deploy/README.md`), and in-app `ui/README.md` remain next to their code so Flutter/web tooling and local onboarding keep working.
