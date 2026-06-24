<?php
/**
 * CLI: download wiki job sprites into assets/images/jobs/
 *
 * Usage (from FluxCP root):
 *   php addons/wiki/tools/fetch-job-sprites.php
 */

$fluxRoot = realpath(__DIR__ . '/../../..');
if ($fluxRoot === false || !is_file($fluxRoot . '/index.php')) {
	fwrite(STDERR, "Run from a FluxCP install (php addons/wiki/tools/fetch-job-sprites.php).\n");
	exit(1);
}

define('FLUX_ROOT', $fluxRoot);
require_once FLUX_ROOT . '/lib/Flux/Config.php';
require_once dirname(__DIR__) . '/lib/wiki.php';
require_once dirname(__DIR__) . '/lib/job-sprite.php';

$ids = wiki_collect_job_sprite_ids();
$ok = 0;
$fail = 0;

echo 'Fetching ' . count($ids) . " job sprites...\n";

foreach ($ids as $jobId) {
	if (wiki_resolve_local_job_sprite_file($jobId) !== null) {
		echo "[skip] $jobId (already cached)\n";
		$ok++;
		continue;
	}

	$path = wiki_download_job_sprite($jobId);
	if ($path !== null) {
		echo "[ok]   $jobId -> $path\n";
		$ok++;
		continue;
	}

	$path = wiki_generate_job_sprite_placeholder($jobId, 'J');
	if ($path !== null) {
		echo "[gen]  $jobId placeholder\n";
		$ok++;
	} else {
		echo "[fail] $jobId\n";
		$fail++;
	}
}

echo "Done. ok=$ok fail=$fail\n";
exit($fail > 0 ? 1 : 0);
