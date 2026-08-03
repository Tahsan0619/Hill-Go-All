# SQL dumps

MySQL/MariaDB dumps for local restore of the `hillgo` database.

## Latest dump (use this)

| File | Notes |
|------|--------|
| **[`HillGo-Last.sql`](HillGo-Last.sql)** | **Latest** dump (generated **2026-08-01**, MariaDB 10.4). Prefer this for new local setups. |

### Import (example)

```bash
# Create DB first if needed, then:
mysql -u root -p hillgo < sql/HillGo-Last.sql
```

Or via phpMyAdmin: import `sql/HillGo-Last.sql` into database `hillgo`.

After import, from `hillgo-backend`:

```bash
php artisan migrate          # apply any migrations newer than the dump
php artisan storage:link
```

## Older dumps (archived)

| File | Approx. age |
|------|-------------|
| [`hillgo-final.sql`](hillgo-final.sql) | Earlier 2026-08-01 dump |
| [`hillgo_backup_before_fixes.sql`](hillgo_backup_before_fixes.sql) | Pre-security-fix backup |
| [`hillgo.sql`](hillgo.sql) | Oldest root dump in this set |

Keep these for historical/diff reference; do not use them for a fresh install unless you have a specific reason.
