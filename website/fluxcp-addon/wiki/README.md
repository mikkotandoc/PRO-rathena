# PRO-Ragnarok Wiki — PHP Site

Self-contained PHP wiki for shared hosting. No Composer or database required.

## Requirements

- PHP **7.4+** (8.x recommended)
- Optional: Apache `mod_rewrite` for pretty URLs (`/page/Getting-Started`)

## Quick local test

From this folder:

```bash
php -S localhost:8080
```

Open [http://localhost:8080](http://localhost:8080) for the Home page.

- Home: `http://localhost:8080/`
- Query-string pages: `http://localhost:8080/index.php?page=Getting-Started`
- Pretty URLs (no built-in server): use Apache with `.htaccess` — `http://localhost/page/Getting-Started`

> PHP's built-in server does **not** read `.htaccess`. Use `?page=Slug` locally, or Apache/XAMPP for rewrite testing.

## Deploy to shared hosting

1. Upload the entire `website/` folder to your host (FTP, SFTP, or file manager).
2. Point the domain or subdomain **document root** at this folder (so `index.php` is the site entry).
   - Example: `wiki.yourserver.com` → `/public_html/wiki/`
3. Ensure PHP 7.4+ is enabled for that directory.
4. If the site lives in a **subdirectory**, edit `website/.htaccess` and set `RewriteBase`:
   ```apache
   RewriteBase /wiki/
   ```
5. If **mod_rewrite is unavailable**, set in `includes/config.php`:
   ```php
   define('WIKI_PRETTY_URLS', false);
   ```
   All links will use `index.php?page=Page-Name`, which works everywhere.

## Updating content

Wiki pages are copied from `docs/wiki/` into `content/` as `.md` files. After editing the repo wiki:

1. Copy updated `.md` files into `website/content/`
2. Re-upload `content/` (or the whole `website/` folder) to the host

No rebuild step is required.

## Structure

```
website/
  index.php              Entry point / router
  .htaccess              Pretty URL rewrites (optional)
  includes/              Config, layout, markdown helpers
  content/               Markdown wiki pages (*.md)
  assets/css/style.css   Theme
  lib/                   Parsedown + ParsedownExtra
  README.md              This file
```

## Security notes

- Only whitelisted page slugs from `includes/config.php` can be loaded.
- Markdown files are blocked from direct HTTP access via `.htaccess`.
- Parsedown safe mode is enabled (no raw HTML injection from markdown).

## Pages

| Slug | File |
|------|------|
| Home | `content/Home.md` |
| Getting-Started | `content/Getting-Started.md` |
| Server-Information | `content/Server-Information.md` |
| Custom-Systems | `content/Custom-Systems.md` |
| NPCs-and-Merchants | `content/NPCs-and-Merchants.md` |
| Items-and-Equipment | `content/Items-and-Equipment.md` |
| Dungeons | `content/Dungeons.md` |
| Commands | `content/Commands.md` |
| Rules | `content/Rules.md` |
| Classes | `content/Classes.md` |
