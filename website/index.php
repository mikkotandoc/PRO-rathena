<?php
/**
 * PRO-Ragnarok Wiki — front controller
 */

require_once __DIR__ . '/includes/config.php';
require_once __DIR__ . '/includes/render.php';

$requested = $_GET['page'] ?? 'Home';
$current_page = wiki_resolve_page($requested);
$is_not_found = false;

if ($current_page === null) {
	http_response_code(404);
	$is_not_found = true;
	$page_title = 'Page Not Found';
	$body = wiki_render_not_found(is_string($requested) ? $requested : '');
} else {
	$page_title = $WIKI_PAGES[$current_page]['title'];
	$body = wiki_render_page($current_page);
}

require __DIR__ . '/includes/header.php';
echo $body;
require __DIR__ . '/includes/footer.php';
