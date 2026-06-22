<?php
/** Sidebar navigation — expects $current_page slug */
?>
<nav class="wiki-nav" aria-label="Wiki pages">
	<ul class="wiki-nav-list">
<?php foreach ($WIKI_PAGES as $slug => $meta): ?>
		<li class="wiki-nav-item<?= $slug === $current_page ? ' is-active' : '' ?>">
			<a href="<?= htmlspecialchars(wiki_page_url($slug), ENT_QUOTES, 'UTF-8') ?>">
				<?= htmlspecialchars($meta['nav'], ENT_QUOTES, 'UTF-8') ?>
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
