<?php
/**
 * Markdown loading and HTML rendering helpers.
 */

require_once WIKI_ROOT . '/lib/Parsedown.php';
require_once WIKI_ROOT . '/lib/ParsedownExtra.php';

/**
 * Read markdown for a whitelisted page slug.
 */
function wiki_load_markdown(string $slug): ?string
{
	global $WIKI_PAGES;

	if (!wiki_is_valid_page($slug)) {
		return null;
	}

	$file = CONTENT_DIR . '/' . $WIKI_PAGES[$slug]['file'];
	$realContent = realpath(CONTENT_DIR);
	$realFile = realpath($file);

	if ($realFile === false || $realContent === false) {
		return null;
	}

	if (strpos($realFile, $realContent) !== 0) {
		return null;
	}

	$content = file_get_contents($realFile);
	return $content === false ? null : $content;
}

/**
 * Rewrite internal .md links to wiki routes.
 */
function wiki_rewrite_internal_links(string $html): string
{
	return preg_replace_callback(
		'/href="([^"#?]+?)(?:\.md)(#[^"]*)?"/i',
		static function (array $matches): string {
			$slug = basename($matches[1]);
			$slug = preg_replace('/\.md$/i', '', $slug);
			$anchor = $matches[2] ?? '';

			if (!wiki_is_valid_page($slug)) {
				return $matches[0];
			}

			return 'href="' . htmlspecialchars(wiki_page_url($slug) . $anchor, ENT_QUOTES, 'UTF-8') . '"';
		},
		$html
	);
}

/**
 * Add id attributes to headings for anchor navigation.
 */
function wiki_add_heading_ids(string $html): string
{
	return preg_replace_callback(
		'/<h([1-6])>(.*?)<\/h\1>/s',
		static function (array $matches): string {
			$level = $matches[1];
			$inner = $matches[2];
			$text = trim(strip_tags($inner));
			$id = wiki_slugify_heading($text);

			if ($id === '') {
				return $matches[0];
			}

			return '<h' . $level . ' id="' . htmlspecialchars($id, ENT_QUOTES, 'UTF-8') . '">' . $inner . '</h' . $level . '>';
		},
		$html
	);
}

function wiki_slugify_heading(string $text): string
{
	$text = strtolower($text);
	$text = preg_replace('/[^a-z0-9]+/', '-', $text);
	return trim($text, '-');
}

/**
 * Convert markdown to sanitized HTML with wiki link fixes.
 */
function wiki_render_markdown(string $markdown): string
{
	$parser = new ParsedownExtra();
	$parser->setSafeMode(true);

	$html = $parser->text($markdown);
	$html = wiki_rewrite_internal_links($html);
	$html = wiki_add_heading_ids($html);

	return $html;
}

/**
 * Render a full wiki page body.
 */
function wiki_render_page(string $slug): string
{
	$markdown = wiki_load_markdown($slug);
	if ($markdown === null) {
		return '<p class="wiki-error">Page content could not be loaded.</p>';
	}

	return '<div class="wiki-article">' . wiki_render_markdown($markdown) . '</div>';
}

/**
 * Simple 404 content block.
 */
function wiki_render_not_found(?string $requested): string
{
	$safe = htmlspecialchars($requested ?? '', ENT_QUOTES, 'UTF-8');
	$home = htmlspecialchars(wiki_page_url('Home'), ENT_QUOTES, 'UTF-8');

	return '<div class="wiki-article wiki-not-found">'
		. '<h1>Page Not Found</h1>'
		. '<p>The wiki page <strong>' . $safe . '</strong> does not exist.</p>'
		. '<p><a href="' . $home . '">Return to Home</a></p>'
		. '</div>';
}
