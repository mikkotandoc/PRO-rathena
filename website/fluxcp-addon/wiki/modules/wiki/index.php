<?php
if (!defined('FLUX_ROOT')) {
	exit;
}

require_once FLUX_ADDON_DIR . '/wiki/lib/wiki.php';

$requested = $params->get('page');
if ($requested === null || $requested === '') {
	$requested = 'Home';
}

$current_page = wiki_resolve_page($requested);
$is_not_found = false;

if ($current_page === null) {
	http_response_code(404);
	$is_not_found = true;
	$page_title = 'Page Not Found';
	$wikiBody = wiki_render_not_found(is_string($requested) ? $requested : '');
} else {
	$page_title = wiki_get_pages()[$current_page]['title'];
	$wikiBody = wiki_render_page($current_page);
}
