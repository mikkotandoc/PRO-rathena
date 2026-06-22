<?php
/** @var string $current_page */
/** @var string $page_title */
/** @var bool $is_not_found */
$full_title = ($current_page === 'Home')
	? WIKI_SITE_NAME
	: $page_title . ' — ' . WIKI_SITE_NAME;
?>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta name="description" content="<?= htmlspecialchars(WIKI_TAGLINE, ENT_QUOTES, 'UTF-8') ?>">
	<title><?= htmlspecialchars($full_title, ENT_QUOTES, 'UTF-8') ?></title>
	<link rel="stylesheet" href="<?= htmlspecialchars(wiki_asset_url('css/style.css'), ENT_QUOTES, 'UTF-8') ?>">
	<link rel="preconnect" href="https://fonts.googleapis.com">
	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
	<link href="https://fonts.googleapis.com/css2?family=Crimson+Pro:ital,wght@0,400;0,600;1,400&family=Source+Sans+3:wght@400;600;700&display=swap" rel="stylesheet">
</head>
<body>
	<a class="wiki-skip-link" href="#wiki-main-content">Skip to content</a>

	<div class="wiki-layout">
		<aside class="wiki-sidebar" id="wiki-sidebar">
			<div class="wiki-brand">
				<a href="<?= htmlspecialchars(wiki_page_url('Home'), ENT_QUOTES, 'UTF-8') ?>" class="wiki-brand-link">
					<span class="wiki-brand-title"><?= htmlspecialchars(WIKI_SITE_NAME, ENT_QUOTES, 'UTF-8') ?></span>
					<span class="wiki-brand-tagline"><?= htmlspecialchars(WIKI_TAGLINE, ENT_QUOTES, 'UTF-8') ?></span>
				</a>
			</div>

			<button type="button" class="wiki-nav-toggle" id="wiki-nav-toggle" aria-expanded="false" aria-controls="wiki-sidebar-nav">
				<span class="wiki-nav-toggle-label">Menu</span>
			</button>

			<div class="wiki-sidebar-nav" id="wiki-sidebar-nav">
				<?php require __DIR__ . '/nav.php'; ?>
			</div>
		</aside>

		<main class="wiki-main" id="wiki-main-content">
			<header class="wiki-page-header">
				<h1 class="wiki-page-title"><?= htmlspecialchars($page_title, ENT_QUOTES, 'UTF-8') ?></h1>
<?php if (!empty($is_not_found)): ?>
				<p class="wiki-page-subtitle">404 — Page not found</p>
<?php elseif ($current_page !== 'Home'): ?>
				<p class="wiki-page-subtitle">
					<a href="<?= htmlspecialchars(wiki_page_url('Home'), ENT_QUOTES, 'UTF-8') ?>">← Back to Home</a>
				</p>
<?php endif; ?>
			</header>

			<div class="wiki-content">
