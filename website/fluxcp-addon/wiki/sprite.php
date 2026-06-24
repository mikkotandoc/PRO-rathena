<?php
/**
 * Serves cached job sprites for the wiki job tree.
 * URL: {BaseURI}addons/wiki/sprite.php?id=7
 */

if (!defined('WIKI_ADDON_DIR')) {
	define('WIKI_ADDON_DIR', str_replace('\\', '/', __DIR__));
}

$fluxRoot = realpath(__DIR__ . '/../../');
if ($fluxRoot !== false && is_file($fluxRoot . '/index.php')) {
	define('FLUX_ROOT', $fluxRoot);
	$fluxData = $fluxRoot . '/data';
	if (is_dir($fluxData)) {
		define('FLUX_DATA_DIR', $fluxData);
	}
}

require_once WIKI_ADDON_DIR . '/lib/job-sprite.php';

$jobId = isset($_GET['id']) ? (int) $_GET['id'] : -1;
$label = isset($_GET['label']) ? (string) $_GET['label'] : '';

wiki_serve_job_sprite($jobId, $label);
