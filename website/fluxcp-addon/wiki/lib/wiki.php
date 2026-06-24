<?php
/**
 * PRO-Ragnarok Wiki — shared helpers for the FluxCP addon.
 */

if (!defined('FLUX_ROOT')) {
	exit;
}

// Resolve paths from this file (addons/wiki/lib/wiki.php) — never rely on CWD.
$wikiAddonDir = str_replace('\\', '/', dirname(__DIR__));
if (!defined('WIKI_ADDON_DIR')) {
	define('WIKI_ADDON_DIR', $wikiAddonDir);
}
if (!defined('WIKI_CONTENT_DIR')) {
	define('WIKI_CONTENT_DIR', WIKI_ADDON_DIR . '/content');
}

require_once __DIR__ . '/Parsedown.php';
require_once __DIR__ . '/ParsedownExtra.php';

/** Whitelisted wiki pages: slug => metadata (must be global — FluxCP includes this file inside a function). */
global $WIKI_PAGES;
$WIKI_PAGES = array(
	'Home' => array(
		'title' => 'PRO-Ragnarok Wiki',
		'nav'   => 'Home',
		'file'  => 'Home.md',
	),
	'Getting-Started' => array(
		'title' => 'Getting Started',
		'nav'   => 'Getting Started',
		'file'  => 'Getting-Started.md',
	),
	'Server-Information' => array(
		'title' => 'Server Information',
		'nav'   => 'Server Information',
		'file'  => 'Server-Information.md',
	),
	'Custom-Systems' => array(
		'title' => 'Custom Systems',
		'nav'   => 'Custom Systems',
		'file'  => 'Custom-Systems.md',
	),
	'NPCs-and-Merchants' => array(
		'title' => 'NPCs & Merchants',
		'nav'   => 'NPCs & Merchants',
		'file'  => 'NPCs-and-Merchants.md',
	),
	'Items-and-Equipment' => array(
		'title' => 'Items & Equipment',
		'nav'   => 'Items & Equipment',
		'file'  => 'Items-and-Equipment.md',
	),
	'Dungeons' => array(
		'title' => 'Dungeons & Instances',
		'nav'   => 'Dungeons & Instances',
		'file'  => 'Dungeons.md',
	),
	'Commands' => array(
		'title' => 'Player Commands',
		'nav'   => 'Player Commands',
		'file'  => 'Commands.md',
	),
	'Rules' => array(
		'title' => 'Server Rules',
		'nav'   => 'Server Rules',
		'file'  => 'Rules.md',
	),
	'Classes' => array(
		'title' => 'Classes & Skills',
		'nav'   => 'Classes & Skills',
		'file'  => 'Classes.md',
	),
);

function wiki_site_name()
{
	$name = Flux::config('WikiSiteName');
	return $name ? $name : 'PRO-Ragnarok Wiki';
}

function wiki_tagline()
{
	$tagline = Flux::config('WikiTagline');
	return $tagline ? $tagline : 'Unofficial player wiki';
}

function wiki_is_valid_page($slug)
{
	$pages = wiki_get_pages();
	return isset($pages[$slug]);
}

function wiki_get_pages()
{
	global $WIKI_PAGES;
	return is_array($WIKI_PAGES) ? $WIKI_PAGES : array();
}

/**
 * Resolve and whitelist a page slug. Returns slug or null if invalid.
 */
function wiki_resolve_page($raw)
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

/**
 * Build a wiki page URL relative to the FluxCP install.
 */
function wiki_page_url($slug)
{
	$basePath = preg_replace('&/+&', '/', rtrim(Flux::config('BaseURI'), '/') . '/');

	if (Flux::config('UseCleanUrls')) {
		$url = $basePath . 'wiki';
		if ($slug !== 'Home') {
			$url .= '?page=' . rawurlencode($slug);
		}
		return $url;
	}

	$url = $basePath . '?module=wiki';
	if ($slug !== 'Home') {
		$url .= '&page=' . rawurlencode($slug);
	}
	return $url;
}

function wiki_asset_url($path)
{
	$basePath = preg_replace('&/+&', '/', rtrim(Flux::config('BaseURI'), '/') . '/');
	return $basePath . 'addons/wiki/assets/' . ltrim($path, '/');
}

function wiki_content_path($slug)
{
	$pages = wiki_get_pages();

	if (!wiki_is_valid_page($slug)) {
		return null;
	}

	return WIKI_CONTENT_DIR . '/' . basename($pages[$slug]['file']);
}

function wiki_load_markdown($slug)
{
	$path = wiki_content_path($slug);
	if ($path === null || !is_file($path) || !is_readable($path)) {
		return null;
	}

	$content = file_get_contents($path);
	return ($content === false) ? null : $content;
}

function wiki_rewrite_internal_links($html)
{
	return preg_replace_callback(
		'/href="([^"#?]+?)(?:\.md)(#[^"]*)?"/i',
		'wiki_rewrite_internal_links_callback',
		$html
	);
}

function wiki_rewrite_internal_links_callback($matches)
{
	$slug = basename($matches[1]);
	$slug = preg_replace('/\.md$/i', '', $slug);
	$anchor = isset($matches[2]) ? $matches[2] : '';

	if (!wiki_is_valid_page($slug)) {
		return $matches[0];
	}

	return 'href="' . htmlspecialchars(wiki_page_url($slug) . $anchor, ENT_QUOTES, 'UTF-8') . '"';
}

function wiki_add_heading_ids($html)
{
	return preg_replace_callback(
		'/<h([1-6])>(.*?)<\/h\1>/s',
		'wiki_add_heading_ids_callback',
		$html
	);
}

function wiki_add_heading_ids_callback($matches)
{
	$level = $matches[1];
	$inner = $matches[2];
	$text = trim(strip_tags($inner));
	$id = wiki_slugify_heading($text);

	if ($id === '') {
		return $matches[0];
	}

	return '<h' . $level . ' id="' . htmlspecialchars($id, ENT_QUOTES, 'UTF-8') . '">' . $inner . '</h' . $level . '>';
}

function wiki_slugify_heading($text)
{
	$text = strtolower($text);
	$text = preg_replace('/[^a-z0-9]+/', '-', $text);
	return trim($text, '-');
}

function wiki_render_markdown($markdown)
{
	$parser = new ParsedownExtra();
	$parser->setSafeMode(true);

	$html = $parser->text($markdown);
	$html = wiki_rewrite_internal_links($html);
	$html = wiki_add_heading_ids($html);

	return $html;
}

function wiki_render_page($slug)
{
	$markdown = wiki_load_markdown($slug);
	if ($markdown === null) {
		$debug = '';
		if (Flux::config('DebugMode')) {
			$path = wiki_content_path($slug);
			if ($path) {
				$debug = is_file($path) ? ' (content file exists but could not be read)' : ' (content file missing)';
			} else {
				$debug = ' (invalid page name)';
			}
		}
		return '<p class="wiki-error">Page content could not be loaded.' . $debug . '</p>';
	}

	try {
		$html = wiki_render_markdown($markdown);
	} catch (Exception $e) {
		if (Flux::config('DebugMode')) {
			return '<p class="wiki-error">Markdown error: ' . htmlspecialchars($e->getMessage(), ENT_QUOTES, 'UTF-8') . '</p>';
		}
		return '<p class="wiki-error">Page content could not be loaded.</p>';
	}

	return '<div class="wiki-article">' . $html . '</div>';
}

function wiki_render_not_found($requested)
{
	$safe = htmlspecialchars($requested ? $requested : '', ENT_QUOTES, 'UTF-8');
	$home = htmlspecialchars(wiki_page_url('Home'), ENT_QUOTES, 'UTF-8');

	return '<div class="wiki-article wiki-not-found">'
		. '<h1>Page Not Found</h1>'
		. '<p>The wiki page <strong>' . $safe . '</strong> does not exist.</p>'
		. '<p><a href="' . $home . '">Return to Home</a></p>'
		. '</div>';
}
