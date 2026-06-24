<?php
/**
 * Local job sprite resolution, validation, caching, and HTTP serving.
 */

function wiki_job_sprite_dir()
{
	return WIKI_ADDON_DIR . '/assets/images/jobs';
}

function wiki_job_sprite_file($jobId, $ext = 'png')
{
	return wiki_job_sprite_dir() . '/' . (int) $jobId . '.' . $ext;
}

function wiki_is_valid_image_file($path)
{
	if (!is_file($path) || !is_readable($path)) {
		return false;
	}

	$size = filesize($path);
	if ($size === false || $size < 400) {
		return false;
	}

	$fh = fopen($path, 'rb');
	if ($fh === false) {
		return false;
	}
	$header = fread($fh, 12);
	fclose($fh);

	if ($header === false || $header === '') {
		return false;
	}

	if (strncmp($header, "\x89PNG\r\n\x1a\n", 8) === 0) {
		return true;
	}
	if (strncmp($header, 'GIF87a', 6) === 0 || strncmp($header, 'GIF89a', 6) === 0) {
		return true;
	}
	if (strncmp($header, "\xFF\xD8\xFF", 3) === 0) {
		return true;
	}
	if (strlen($header) >= 12 && substr($header, 0, 4) === 'RIFF' && substr($header, 8, 4) === 'WEBP') {
		return true;
	}

	return false;
}

function wiki_flux_job_image_path($jobId, $gender = 'M')
{
	if (!defined('FLUX_DATA_DIR')) {
		return null;
	}

	$path = sprintf(FLUX_DATA_DIR . '/jobs/images/%s/%d.gif', $gender, (int) $jobId);
	if (wiki_is_valid_image_file($path)) {
		return $path;
	}

	if ($gender === 'M') {
		return wiki_flux_job_image_path($jobId, 'F');
	}

	return null;
}

function wiki_flux_job_image_url($jobId, $gender = 'M')
{
	$path = wiki_flux_job_image_path($jobId, $gender);
	if ($path === null || !function_exists('Flux')) {
		return null;
	}

	$basePath = preg_replace('&/+&', '/', rtrim(Flux::config('BaseURI'), '/') . '/');
	$gender = ($gender === 'F') ? 'F' : 'M';
	return $basePath . 'data/jobs/images/' . $gender . '/' . (int) $jobId . '.gif';
}

function wiki_resolve_local_job_sprite_file($jobId)
{
	$jobId = (int) $jobId;
	$dir = wiki_job_sprite_dir();

	foreach (array('png', 'webp', 'gif', 'jpg', 'jpeg') as $ext) {
		$path = $dir . '/' . $jobId . '.' . $ext;
		if (wiki_is_valid_image_file($path)) {
			return $path;
		}
	}

	$fluxPath = wiki_flux_job_image_path($jobId);
	if ($fluxPath !== null) {
		return $fluxPath;
	}

	return null;
}

function wiki_sprite_endpoint_url($jobId)
{
	if (function_exists('Flux') && Flux::config('BaseURI') !== null) {
		$basePath = preg_replace('&/+&', '/', rtrim(Flux::config('BaseURI'), '/') . '/');
	} else {
		$basePath = '/';
	}
	return $basePath . 'addons/wiki/sprite.php?id=' . (int) $jobId;
}

function wiki_asset_url_for_sprite($relativePath)
{
	if (function_exists('Flux') && Flux::config('BaseURI') !== null) {
		$basePath = preg_replace('&/+&', '/', rtrim(Flux::config('BaseURI'), '/') . '/');
		return $basePath . 'addons/wiki/assets/' . ltrim($relativePath, '/');
	}
	return 'assets/' . ltrim($relativePath, '/');
}

function wiki_job_sprite_public_url($jobId)
{
	$jobId = (int) $jobId;
	$local = wiki_resolve_local_job_sprite_file($jobId);

	if ($local !== null && strpos(str_replace('\\', '/', $local), '/assets/images/jobs/') !== false) {
		$basename = basename($local);
		if (function_exists('wiki_asset_url')) {
			return wiki_asset_url('images/jobs/' . $basename);
		}
		return wiki_asset_url_for_sprite('images/jobs/' . $basename);
	}

	if ($local !== null) {
		$fluxUrl = wiki_flux_job_image_url($jobId);
		if ($fluxUrl !== null) {
			return $fluxUrl;
		}
	}

	return wiki_sprite_endpoint_url($jobId);
}

function wiki_job_sprite_mime($path)
{
	$fh = fopen($path, 'rb');
	if ($fh !== false) {
		$header = fread($fh, 12);
		fclose($fh);
		if ($header !== false && $header !== '') {
			if (strncmp($header, "\x89PNG\r\n\x1a\n", 8) === 0) {
				return 'image/png';
			}
			if (strncmp($header, 'GIF87a', 6) === 0 || strncmp($header, 'GIF89a', 6) === 0) {
				return 'image/gif';
			}
			if (strncmp($header, "\xFF\xD8\xFF", 3) === 0) {
				return 'image/jpeg';
			}
			if (strlen($header) >= 12 && substr($header, 0, 4) === 'RIFF' && substr($header, 8, 4) === 'WEBP') {
				return 'image/webp';
			}
		}
	}

	$ext = strtolower(pathinfo($path, PATHINFO_EXTENSION));
	switch ($ext) {
		case 'png': return 'image/png';
		case 'gif': return 'image/gif';
		case 'jpg':
		case 'jpeg': return 'image/jpeg';
		case 'webp': return 'image/webp';
		default: return 'application/octet-stream';
	}
}

function wiki_guess_image_extension($binary)
{
	if (strncmp($binary, "\x89PNG\r\n\x1a\n", 8) === 0) {
		return 'png';
	}
	if (strncmp($binary, 'GIF87a', 6) === 0 || strncmp($binary, 'GIF89a', 6) === 0) {
		return 'gif';
	}
	if (strncmp($binary, "\xFF\xD8\xFF", 3) === 0) {
		return 'jpg';
	}
	if (strlen($binary) >= 12 && substr($binary, 0, 4) === 'RIFF' && substr($binary, 8, 4) === 'WEBP') {
		return 'webp';
	}
	return null;
}

function wiki_download_job_sprite($jobId)
{
	$jobId = (int) $jobId;
	if ($jobId < 0) {
		return null;
	}

	$sources = array(
		'https://static.divine-pride.net/images/jobs/png/' . $jobId . '.png',
		'https://www.divine-pride.net/images/jobs/png/' . $jobId . '.png',
	);

	$context = stream_context_create(array(
		'http' => array(
			'method'  => 'GET',
			'timeout' => 12,
			'header'  => "User-Agent: PRO-Ragnarok-Wiki/1.0\r\nReferer: https://www.divine-pride.net/\r\n",
		),
		'ssl' => array(
			'verify_peer'      => true,
			'verify_peer_name' => true,
		),
	));

	foreach ($sources as $url) {
		$binary = @file_get_contents($url, false, $context);
		if ($binary === false || strlen($binary) < 400) {
			continue;
		}
		if (strncmp($binary, '<!DOCTYPE', 9) === 0 || strncmp($binary, '<html', 5) === 0) {
			continue;
		}
		if (stripos($binary, 'CPakEx') !== false) {
			continue;
		}

		$ext = wiki_guess_image_extension($binary);
		if ($ext === null) {
			continue;
		}

		$dir = wiki_job_sprite_dir();
		if (!is_dir($dir)) {
			@mkdir($dir, 0755, true);
		}

		$target = wiki_job_sprite_file($jobId, $ext);
		if (@file_put_contents($target, $binary) !== false && wiki_is_valid_image_file($target)) {
			return $target;
		}
	}

	return null;
}

function wiki_generate_job_sprite_placeholder($jobId, $label = '')
{
	if (!function_exists('imagecreatetruecolor')) {
		return null;
	}

	$jobId = (int) $jobId;
	$label = trim($label);
	if ($label === '') {
		$label = '#';
	}
	$letter = function_exists('mb_substr') ? mb_substr($label, 0, 1) : substr($label, 0, 1);

	$w = 72;
	$h = 72;
	$img = imagecreatetruecolor($w, $h);
	if ($img === false) {
		return null;
	}

	imagealphablending($img, true);
	imagesavealpha($img, true);

	$bg = imagecolorallocate($img, 28, 37, 48);
	$border = imagecolorallocate($img, 154, 123, 26);
	$gold = imagecolorallocate($img, 201, 162, 39);
	$text = imagecolorallocate($img, 240, 230, 210);
	imagefilledrectangle($img, 0, 0, $w - 1, $h - 1, $bg);
	imagerectangle($img, 1, 1, $w - 2, $h - 2, $border);
	imagerectangle($img, 2, 2, $w - 3, $h - 3, $border);

	$font = 5;
	$tw = imagefontwidth($font) * strlen($letter);
	$th = imagefontheight($font);
	imagestring($img, $font, (int) (($w - $tw) / 2), (int) (($h - $th) / 2) - 4, $letter, $text);
	imagestring($img, 2, 4, $h - 12, (string) $jobId, $gold);

	$dir = wiki_job_sprite_dir();
	if (!is_dir($dir)) {
		@mkdir($dir, 0755, true);
	}

	$target = wiki_job_sprite_file($jobId, 'png');
	if (!imagepng($img, $target)) {
		imagedestroy($img);
		return null;
	}
	imagedestroy($img);

	return wiki_is_valid_image_file($target) ? $target : null;
}

function wiki_collect_job_sprite_ids()
{
	require_once WIKI_ADDON_DIR . '/lib/jobtree.php';
	$tree = wiki_get_job_tree();
	$ids = array();

	$collect = function ($job) use (&$ids) {
		if (isset($job['id'])) {
			$ids[(int) $job['id']] = true;
		}
		if (!empty($job['id_f'])) {
			$ids[(int) $job['id_f']] = true;
		}
	};

	$collect($tree['novice']);
	foreach ($tree['super_novice']['chain'] as $step) {
		$collect($step);
	}

	foreach (array('main', 'expanded', 'coming_soon') as $section) {
		if (empty($tree[$section])) {
			continue;
		}
		foreach ($tree[$section] as $branch) {
			$collect($branch['first']);
			foreach ($branch['paths'] as $path) {
				$collect($path['second']);
				foreach ($path['chain'] as $step) {
					$collect($step);
				}
			}
		}
	}

	ksort($ids, SORT_NUMERIC);
	return array_keys($ids);
}

function wiki_serve_job_sprite($jobId, $label = '')
{
	$jobId = (int) $jobId;
	if ($jobId < 0) {
		http_response_code(404);
		exit;
	}

	$path = wiki_resolve_local_job_sprite_file($jobId);
	if ($path === null) {
		$path = wiki_download_job_sprite($jobId);
	}
	if ($path === null) {
		$path = wiki_generate_job_sprite_placeholder($jobId, $label);
	}
	if ($path === null || !wiki_is_valid_image_file($path)) {
		http_response_code(404);
		exit;
	}

	header('Content-Type: ' . wiki_job_sprite_mime($path));
	header('Cache-Control: public, max-age=604800');
	header('X-Content-Type-Options: nosniff');
	readfile($path);
	exit;
}
