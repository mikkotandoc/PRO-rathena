# PRO-Ragnarok Wiki — FluxCP Addon

Markdown wiki module for [FluxCP](https://github.com/rathena/FluxCP). Renders the PRO-rathena player wiki inside your control panel with FluxCP header, sidebar, and login — no database required.

## Requirements

- FluxCP (PHP 7.3+)
- No extra Composer packages or SQL tables

## Install (step-by-step)

### 1. Copy the addon folder

Copy the entire `wiki` folder from this package into your FluxCP `addons` directory:

```
your-fluxcp/
  addons/
    wiki/          ← copy website/fluxcp-addon/wiki/ here
      config/
      modules/
      themes/
      content/
      lib/
      assets/
      lang/
```

**Windows example** (adjust paths to your install):

```powershell
Copy-Item -Recurse "C:\path\to\PRO-rathena\website\fluxcp-addon\wiki" "C:\path\to\your-fluxcp\addons\wiki"
```

**Linux example:**

```bash
cp -r /path/to/PRO-rathena/website/fluxcp-addon/wiki /var/www/fluxcp/addons/wiki
```

FluxCP auto-detects any folder under `addons/` — no registry file is needed.

### 2. Verify file permissions

Ensure the web server can read all files under `addons/wiki/`. Markdown in `content/` is blocked from direct download via `.htaccess`, but PHP must still read those files.

### 3. Open the wiki in your browser

Replace `your-site.com` and `fluxcp` with your `ServerAddress` and `BaseURI` from `config/application.php`.

| URL style | Home page | Example article |
|-----------|-----------|-----------------|
| Query string (default) | `https://your-site.com/fluxcp/?module=wiki` | `https://your-site.com/fluxcp/?module=wiki&page=Getting-Started` |
| Clean URLs (`UseCleanUrls` = true) | `https://your-site.com/fluxcp/wiki` | `https://your-site.com/fluxcp/wiki?page=Getting-Started` |

### 4. Confirm the menu link

The addon merges a **Wiki** item into the main menu (`MainMenuLabel`). After install, refresh FluxCP and look for **Wiki** in the top navigation.

If it does not appear:

1. Clear your browser cache and reload.
2. Confirm `addons/wiki/config/addon.php` exists.
3. If you use a custom theme, ensure it renders `MenuItems` from config (default and bootstrap themes do).

### 5. (Optional) Customize settings

Edit `addons/wiki/config/addon.php`:

```php
'WikiSiteName' => 'PRO-Ragnarok Wiki',
'WikiTagline'  => 'Your tagline here',
```

Edit `addons/wiki/lang/en_us.php` to change the menu label (`WikiLabel`).

### 6. (Optional) Custom FluxCP theme

Views are provided for **default** and **bootstrap** themes. For another theme (e.g. `hurtfreev2`):

1. Create `addons/wiki/themes/your-theme/wiki/index.php`
2. Add one line:

```php
<?php if (!defined('FLUX_ROOT')) exit;
require FLUX_ADDON_DIR . '/wiki/themes/wiki-view.php';
```

## Updating wiki content

1. Edit `.md` files in `addons/wiki/content/` (or sync from `website/content/` in this repo).
2. Upload only the changed files — no rebuild or `@reload` needed.

To add a new page:

1. Add `content/Your-Page.md`
2. Register the slug in `addons/wiki/lib/wiki.php` under `$WIKI_PAGES`

## Package layout

```
addons/wiki/
  config/
    addon.php       Menu + site settings (merged into FluxCP config)
    access.php      Public read access (AccountLevel::ANYONE)
  modules/wiki/
    index.php       Controller — loads markdown, sets $wikiBody
  themes/
    wiki-view.php   Shared HTML layout (sidebar + article)
    default/wiki/index.php
    bootstrap/wiki/index.php
  content/*.md      Wiki articles
  lib/
    wiki.php        Page registry, URL helpers, markdown render
    Parsedown.php
    ParsedownExtra.php
  assets/css/style.css
  lang/en_us.php
```

## Standalone site (without FluxCP)

The original standalone wiki remains in `website/` (`index.php`, `includes/`, etc.) for hosting on a subdomain without FluxCP. For production with FluxCP, use this addon instead.

## Troubleshooting

| Problem | Fix |
|---------|-----|
| 404 / “Page not found” (FluxCP) | Confirm `addons/wiki/modules/wiki/index.php` exists and folder name is exactly `wiki`. |
| Blank page / PHP error | Enable `DebugMode` in `config/application.php` temporarily. Check `data/logs/errors/exceptions/`. |
| CSS missing | Open `https://your-site/fluxcp/addons/wiki/assets/css/style.css` in the browser. If 404, verify the `assets/` folder was copied. |
| **"Page content could not be loaded"** | 1) Upload **`addons/wiki/content/`** with all `.md` files (most common). 2) Re-upload **`addons/wiki/lib/wiki.php`** (latest path fix). 3) Enable `DebugMode` in `config/application.php` temporarily — the wiki will show the exact missing file path. |
| Markdown shows raw text | Confirm `lib/Parsedown.php` and `lib/ParsedownExtra.php` are present. |
| Menu label shows “WikiLabel” | Add or fix `addons/wiki/lang/en_us.php`, or add `WikiLabel` to your FluxCP language file. |
| Clean URL `/wiki` fails | Set `UseCleanUrls` => true and ensure FluxCP `.htaccess` rewrite rules are active. |

## Security notes

- Only whitelisted slugs in `lib/wiki.php` can be loaded.
- Parsedown safe mode is enabled (no raw HTML from markdown).
- `content/.htaccess` denies direct HTTP access to `.md` files on Apache.
