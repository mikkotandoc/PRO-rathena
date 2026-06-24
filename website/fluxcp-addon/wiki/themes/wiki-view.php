<?php
/**
 * Shared wiki view partial for all FluxCP themes.
 * Expects: $current_page, $page_title, $wikiBody, $is_not_found
 */
if (!defined('FLUX_ROOT')) {
	exit;
}
?>
<link rel="stylesheet" href="<?php echo htmlspecialchars(wiki_asset_url('css/style.css'), ENT_QUOTES, 'UTF-8') ?>">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Crimson+Pro:ital,wght@0,400;0,600;1,400&family=Source+Sans+3:wght@400;600;700&display=swap" rel="stylesheet">

<div class="pro-wiki">
	<div class="wiki-layout">
		<aside class="wiki-sidebar" id="wiki-sidebar">
			<div class="wiki-brand">
				<a href="<?php echo htmlspecialchars(wiki_page_url('Home'), ENT_QUOTES, 'UTF-8') ?>" class="wiki-brand-link">
					<span class="wiki-brand-title"><?php echo htmlspecialchars(wiki_site_name(), ENT_QUOTES, 'UTF-8') ?></span>
					<span class="wiki-brand-tagline"><?php echo htmlspecialchars(wiki_tagline(), ENT_QUOTES, 'UTF-8') ?></span>
				</a>
			</div>

			<button type="button" class="wiki-nav-toggle" id="wiki-nav-toggle" aria-expanded="false" aria-controls="wiki-sidebar-nav">
				<span class="wiki-nav-toggle-label">Menu</span>
			</button>

			<div class="wiki-sidebar-nav" id="wiki-sidebar-nav">
				<nav class="wiki-nav" aria-label="Wiki pages">
					<ul class="wiki-nav-list">
<?php foreach (wiki_get_pages() as $slug => $meta): ?>
						<li class="wiki-nav-item<?php echo $slug === $current_page ? ' is-active' : '' ?>">
							<a href="<?php echo htmlspecialchars(wiki_page_url($slug), ENT_QUOTES, 'UTF-8') ?>">
								<?php echo htmlspecialchars($meta['nav'], ENT_QUOTES, 'UTF-8') ?>
							</a>
						</li>
<?php endforeach; ?>
					</ul>

					<div class="wiki-nav-external">
						<p class="wiki-nav-heading">External</p>
						<ul class="wiki-nav-list">
							<li class="wiki-nav-item">
								<a href="https://www.divine-pride.net/" target="_blank" rel="noopener noreferrer">Divine Pride</a>
							</li>
							<li class="wiki-nav-item">
								<a href="https://github.com/rathena/rathena/wiki" target="_blank" rel="noopener noreferrer">rAthena Wiki</a>
							</li>
						</ul>
					</div>
				</nav>
			</div>
		</aside>

		<main class="wiki-main" id="wiki-main-content">
			<header class="wiki-page-header">
				<h1 class="wiki-page-title"><?php echo htmlspecialchars($page_title, ENT_QUOTES, 'UTF-8') ?></h1>
<?php if (!empty($is_not_found)): ?>
				<p class="wiki-page-subtitle">404 — Page not found</p>
<?php elseif ($current_page !== 'Home'): ?>
				<p class="wiki-page-subtitle">
					<a href="<?php echo htmlspecialchars(wiki_page_url('Home'), ENT_QUOTES, 'UTF-8') ?>">← Back to Home</a>
				</p>
<?php endif; ?>
			</header>

			<div class="wiki-content">
				<?php echo $wikiBody ?>
			</div>

			<footer class="wiki-footer">
				<p>
					Unofficial wiki for <strong>PRO-Ragnarok</strong> (PRO-rathena).
					Game data may change; confirm in-game or with staff.
				</p>
				<p class="wiki-footer-links">
					<a href="<?php echo htmlspecialchars(wiki_page_url('Home'), ENT_QUOTES, 'UTF-8') ?>">Home</a>
					·
					<a href="https://www.divine-pride.net/" target="_blank" rel="noopener noreferrer">Divine Pride</a>
				</p>
			</footer>
		</main>
	</div>
</div>

<script>
(function () {
	var toggle = document.getElementById('wiki-nav-toggle');
	var sidebar = document.getElementById('wiki-sidebar');
	if (!toggle || !sidebar) return;

	toggle.addEventListener('click', function () {
		var open = sidebar.classList.toggle('is-nav-open');
		toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
	});
})();
</script>
