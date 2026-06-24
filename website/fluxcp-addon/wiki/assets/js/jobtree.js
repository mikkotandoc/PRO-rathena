(function () {
	'use strict';

	var root = document.getElementById('wiki-jobtree');
	if (!root) {
		return;
	}

	root.querySelectorAll('.wiki-jobtree-sprite').forEach(function (img) {
		img.addEventListener('error', function () {
			img.hidden = true;
			var fallback = img.nextElementSibling;
			if (fallback && fallback.classList.contains('wiki-jobtree-sprite-fallback')) {
				fallback.hidden = false;
			}
		});
	});

	var buttons = root.querySelectorAll('.wiki-jobtree-second-btn');

	function closeAll(exceptId) {
		buttons.forEach(function (btn) {
			var targetId = btn.getAttribute('data-jobtree-target');
			var panel = targetId ? document.getElementById(targetId) : null;
			if (targetId === exceptId) {
				return;
			}
			btn.classList.remove('is-active');
			btn.setAttribute('aria-expanded', 'false');
			if (panel) {
				panel.hidden = true;
			}
		});
	}

	buttons.forEach(function (btn) {
		btn.addEventListener('click', function () {
			var targetId = btn.getAttribute('data-jobtree-target');
			var panel = targetId ? document.getElementById(targetId) : null;
			if (!panel) {
				return;
			}

			var isOpen = !panel.hidden;
			closeAll(null);

			if (!isOpen) {
				panel.hidden = false;
				btn.classList.add('is-active');
				btn.setAttribute('aria-expanded', 'true');
				panel.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
			}
		});
	});
})();
