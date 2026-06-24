<?php
/**
 * PRO-Ragnarok Wiki — site configuration
 */

define('WIKI_ROOT', dirname(__DIR__));
define('CONTENT_DIR', WIKI_ROOT . '/content');

/**
 * Pretty URLs (/page/Slug) when mod_rewrite is available.
 * Auto-disabled on PHP's built-in dev server; set false manually if needed.
 */
$wikiPrettyUrls = true;
if (strpos($_SERVER['SERVER_SOFTWARE'] ?? '', 'Development Server') !== false) {
	$wikiPrettyUrls = false;
}
define('WIKI_PRETTY_URLS', $wikiPrettyUrls);

/** Whitelisted wiki pages: slug => metadata */
$WIKI_PAGES = [
	'Home' => [
		'title' => 'PRO-Ragnarok Wiki',
		'nav'   => 'Home',
		'file'  => 'Home.md',
	],
	'Getting-Started' => [
		'title' => 'Getting Started',
		'nav'   => 'Getting Started',
		'file'  => 'Getting-Started.md',
	],
	'Server-Information' => [
		'title' => 'Server Information',
		'nav'   => 'Server Information',
		'file'  => 'Server-Information.md',
	],
	'Custom-Systems' => [
		'title' => 'Custom Systems',
		'nav'   => 'Custom Systems',
		'file'  => 'Custom-Systems.md',
	],
	'NPCs-and-Merchants' => [
		'title' => 'NPCs & Merchants',
		'nav'   => 'NPCs & Merchants',
		'file'  => 'NPCs-and-Merchants.md',
	],
	'Items-and-Equipment' => [
		'title' => 'Items & Equipment',
		'nav'   => 'Items & Equipment',
		'file'  => 'Items-and-Equipment.md',
	],
	'Dungeons' => [
		'title' => 'Dungeons & Instances',
		'nav'   => 'Dungeons & Instances',
		'file'  => 'Dungeons.md',
	],
	'Commands' => [
		'title' => 'Player Commands',
		'nav'   => 'Player Commands',
		'file'  => 'Commands.md',
	],
	'Rules' => [
		'title' => 'Server Rules',
		'nav'   => 'Server Rules',
		'file'  => 'Rules.md',
	],
	'Classes' => [
		'title' => 'Classes & Skills',
		'nav'   => 'Classes & Skills',
		'file'  => 'Classes.md',
	],
];

define('WIKI_SITE_NAME', 'PRO-Ragnarok Wiki');
define('WIKI_TAGLINE', 'Unofficial player wiki for the PRO-rathena private server');

/**
 * Base URL path for the wiki (trailing slash), e.g. "/" or "/wiki/".
 */
function wiki_base_path(): string
{
	static $base = null;
	if ($base !== null) {
		return $base;
	}

	$script = $_SERVER['SCRIPT_NAME'] ?? '/index.php';
	$dir = str_replace('\\', '/', dirname($script));
	if ($dir === '/' || $dir === '.') {
		$base = '/';
	} else {
		$base = rtrim($dir, '/') . '/';
	}

	return $base;
}

function wiki_is_valid_page(string $slug): bool
{
	global $WIKI_PAGES;
	return isset($WIKI_PAGES[$slug]);
}

/**
 * Resolve and whitelist a page slug. Returns slug or null if invalid.
 */
function wiki_resolve_page(?string $raw): ?string
{
	if ($raw === null || $raw === '' || $raw === 'Home') {
		return 'Home';
	}

	$slug = basename($raw);
	$slug = preg_replace('/\.md$/i', '', $slug);

	if (!preg_match('/^[A-Za-z0-9_-]+$/', $slug)) {
		return null;
	}

	if (!wiki_is_valid_page($slug)) {
		return null;
	}

	return $slug;
}

function wiki_page_url(string $slug): string
{
	$base = wiki_base_path();

	if ($slug === 'Home') {
		return $base;
	}

	if (WIKI_PRETTY_URLS) {
		return $base . 'page/' . rawurlencode($slug);
	}

	return $base . 'index.php?page=' . rawurlencode($slug);
}

function wiki_asset_url(string $path): string
{
	return wiki_base_path() . 'assets/' . ltrim($path, '/');
}
