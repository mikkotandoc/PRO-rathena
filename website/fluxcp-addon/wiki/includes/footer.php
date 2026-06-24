
			</div><!-- .wiki-content -->

			<footer class="wiki-footer">
				<p>
					Unofficial wiki for <strong>PRO-Ragnarok</strong>.
					Game data may change; confirm in-game or with staff.
				</p>
				<p class="wiki-footer-links">
					<a href="<?= htmlspecialchars(wiki_page_url('Home'), ENT_QUOTES, 'UTF-8') ?>">Home</a>
					·
					<a href="https://www.divine-pride.net/" target="_blank" rel="noopener noreferrer">Divine Pride</a>
				</p>
			</footer>
		</main>
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
</body>
</html>
