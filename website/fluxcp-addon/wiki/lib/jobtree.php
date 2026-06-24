<?php
/**
 * Renewal job tree data and HTML renderer for the Classes wiki page.
 */

if (!defined('FLUX_ROOT')) {
	exit;
}

/**
 * @return array Renewal job tree (PRO-Ragnarok / standard kRO paths).
 */
function wiki_get_job_tree()
{
	return array(
		'novice' => array(
			'id'   => 0,
			'name' => 'Novice',
		),
		'super_novice' => array(
			'label' => 'Super Novice Path',
			'chain' => array(
				array('tier' => '2nd', 'name' => 'Super Novice', 'id' => 23),
				array('tier' => 'Expanded', 'name' => 'Hyper Novice', 'id' => 4306),
			),
		),
		'main' => array(
			array(
				'first' => array('id' => 1, 'name' => 'Swordman'),
				'paths' => array(
					array(
						'key'    => 'knight',
						'second' => array('id' => 7, 'name' => 'Knight'),
						'chain'  => array(
							array('tier' => 'Trans', 'name' => 'Lord Knight', 'id' => 4008),
							array('tier' => '3rd', 'name' => 'Rune Knight', 'id' => 4054),
							array('tier' => '4th', 'name' => 'Dragon Knight', 'id' => 4252),
						),
					),
					array(
						'key'    => 'crusader',
						'second' => array('id' => 14, 'name' => 'Crusader'),
						'chain'  => array(
							array('tier' => 'Trans', 'name' => 'Paladin', 'id' => 4015),
							array('tier' => '3rd', 'name' => 'Royal Guard', 'id' => 4066),
							array('tier' => '4th', 'name' => 'Imperial Guard', 'id' => 4258),
						),
					),
				),
			),
			array(
				'first' => array('id' => 2, 'name' => 'Magician'),
				'paths' => array(
					array(
						'key'    => 'wizard',
						'second' => array('id' => 9, 'name' => 'Wizard'),
						'chain'  => array(
							array('tier' => 'Trans', 'name' => 'High Wizard', 'id' => 4010),
							array('tier' => '3rd', 'name' => 'Warlock', 'id' => 4055),
							array('tier' => '4th', 'name' => 'Arch Mage', 'id' => 4255),
						),
					),
					array(
						'key'    => 'sage',
						'second' => array('id' => 16, 'name' => 'Sage'),
						'chain'  => array(
							array('tier' => 'Trans', 'name' => 'Professor', 'id' => 4016),
							array('tier' => '3rd', 'name' => 'Sorcerer', 'id' => 4067),
							array('tier' => '4th', 'name' => 'Elemental Master', 'id' => 4261),
						),
					),
				),
			),
			array(
				'first' => array('id' => 5, 'name' => 'Merchant'),
				'paths' => array(
					array(
						'key'    => 'blacksmith',
						'second' => array('id' => 10, 'name' => 'Blacksmith'),
						'chain'  => array(
							array('tier' => 'Trans', 'name' => 'Whitesmith', 'id' => 4011),
							array('tier' => '3rd', 'name' => 'Mechanic', 'id' => 4058),
							array('tier' => '4th', 'name' => 'Meister', 'id' => 4253),
						),
					),
					array(
						'key'    => 'alchemist',
						'second' => array('id' => 18, 'name' => 'Alchemist'),
						'chain'  => array(
							array('tier' => 'Trans', 'name' => 'Creator', 'id' => 4019),
							array('tier' => '3rd', 'name' => 'Geneticist', 'id' => 4071),
							array('tier' => '4th', 'name' => 'Biolo', 'id' => 4259),
						),
					),
				),
			),
			array(
				'first' => array('id' => 6, 'name' => 'Thief'),
				'paths' => array(
					array(
						'key'    => 'assassin',
						'second' => array('id' => 12, 'name' => 'Assassin'),
						'chain'  => array(
							array('tier' => 'Trans', 'name' => 'Assassin Cross', 'id' => 4013),
							array('tier' => '3rd', 'name' => 'Guillotine Cross', 'id' => 4059),
							array('tier' => '4th', 'name' => 'Shadow Cross', 'id' => 4254),
						),
					),
					array(
						'key'    => 'rogue',
						'second' => array('id' => 17, 'name' => 'Rogue'),
						'chain'  => array(
							array('tier' => 'Trans', 'name' => 'Stalker', 'id' => 4017),
							array('tier' => '3rd', 'name' => 'Shadow Chaser', 'id' => 4072),
							array('tier' => '4th', 'name' => 'Abyss Chaser', 'id' => 4260),
						),
					),
				),
			),
			array(
				'first' => array('id' => 3, 'name' => 'Archer'),
				'paths' => array(
					array(
						'key'    => 'hunter',
						'second' => array('id' => 11, 'name' => 'Hunter'),
						'chain'  => array(
							array('tier' => 'Trans', 'name' => 'Sniper', 'id' => 4012),
							array('tier' => '3rd', 'name' => 'Ranger', 'id' => 4056),
							array('tier' => '4th', 'name' => 'Wind Hawk', 'id' => 4257),
						),
					),
					array(
						'key'    => 'bard',
						'second' => array('id' => 19, 'id_f' => 20, 'name' => 'Bard / Dancer'),
						'chain'  => array(
							array('tier' => 'Trans', 'name' => 'Clown / Gypsy', 'id' => 4020, 'id_f' => 4021),
							array('tier' => '3rd', 'name' => 'Minstrel / Wanderer', 'id' => 4068, 'id_f' => 4069),
							array('tier' => '4th', 'name' => 'Troubadour / Trouvere', 'id' => 4263, 'id_f' => 4264),
						),
					),
				),
			),
			array(
				'first' => array('id' => 4, 'name' => 'Acolyte'),
				'paths' => array(
					array(
						'key'    => 'priest',
						'second' => array('id' => 8, 'name' => 'Priest'),
						'chain'  => array(
							array('tier' => 'Trans', 'name' => 'High Priest', 'id' => 4009),
							array('tier' => '3rd', 'name' => 'Arch Bishop', 'id' => 4057),
							array('tier' => '4th', 'name' => 'Cardinal', 'id' => 4256),
						),
					),
					array(
						'key'    => 'monk',
						'second' => array('id' => 15, 'name' => 'Monk'),
						'chain'  => array(
							array('tier' => 'Trans', 'name' => 'Champion', 'id' => 4014),
							array('tier' => '3rd', 'name' => 'Sura', 'id' => 4070),
							array('tier' => '4th', 'name' => 'Inquisitor', 'id' => 4262),
						),
					),
				),
			),
		),
		'expanded' => array(
			array(
				'first' => array('id' => 4046, 'name' => 'Taekwon'),
				'paths' => array(
					array(
						'key'    => 'star_gladiator',
						'second' => array('id' => 4047, 'name' => 'Star Gladiator'),
						'chain'  => array(
							array('tier' => 'Expanded', 'name' => 'Star Emperor', 'id' => 4239),
						),
					),
					array(
						'key'    => 'soul_linker',
						'second' => array('id' => 4049, 'name' => 'Soul Linker'),
						'chain'  => array(
							array('tier' => 'Expanded', 'name' => 'Soul Reaper', 'id' => 4240),
						),
					),
				),
			),
			array(
				'first' => array('id' => 25, 'name' => 'Ninja'),
				'paths' => array(
					array(
						'key'    => 'kagerou_oboro',
						'second' => array('id' => 4211, 'id_f' => 4212, 'name' => 'Kagerou / Oboro'),
						'chain'  => array(),
					),
				),
			),
			array(
				'first' => array('id' => 24, 'name' => 'Gunslinger'),
				'paths' => array(
					array(
						'key'    => 'rebellion',
						'second' => array('id' => 4215, 'name' => 'Rebellion'),
						'chain'  => array(
							array('tier' => 'Expanded', 'name' => 'Night Watch', 'id' => 4305),
						),
					),
				),
			),
			array(
				'first' => array('id' => 4218, 'name' => 'Summoner (Doram)'),
				'paths' => array(
					array(
						'key'    => 'spirit_handler',
						'second' => array('id' => 4307, 'name' => 'Spirit Handler'),
						'chain'  => array(),
					),
				),
			),
		),
		'coming_soon' => array(
			array(
				'first' => array('id' => 4351, 'name' => 'Druid', 'coming_soon' => true),
				'paths' => array(
					array(
						'key'    => 'karnos',
						'second' => array('id' => 4353, 'name' => 'Karnos', 'coming_soon' => true),
						'chain'  => array(
							array('tier' => '3rd', 'name' => 'Alitea', 'id' => 4355, 'coming_soon' => true),
						),
					),
				),
			),
		),
	);
}

/**
 * Remote + local sprite URL candidates for a client job ID.
 *
 * @return string[]
 */
function wiki_job_sprite_urls($jobId)
{
	$jobId = (int) $jobId;
	if ($jobId < 0) {
		return array();
	}

	require_once WIKI_ADDON_DIR . '/lib/job-sprite.php';
	return array(wiki_job_sprite_public_url($jobId));
}

function wiki_jobtree_esc($text)
{
	return htmlspecialchars($text, ENT_QUOTES, 'UTF-8');
}

function wiki_job_is_coming_soon($job)
{
	return !empty($job['coming_soon']);
}

function wiki_job_sprite_ids($job)
{
	$ids = array();
	if (isset($job['id'])) {
		$ids[] = (int) $job['id'];
	}
	if (!empty($job['id_f'])) {
		$ids[] = (int) $job['id_f'];
	}
	return $ids;
}

function wiki_render_job_sprite($jobId, $label, $extraClass = '')
{
	$jobId = (int) $jobId;
	$urls = wiki_job_sprite_urls($jobId);
	$class = 'wiki-jobtree-sprite' . ($extraClass ? ' ' . $extraClass : '');
	$fallback = mb_substr($label, 0, 1);

	if (empty($urls)) {
		return '<span class="wiki-jobtree-sprite-fallback">' . wiki_jobtree_esc($fallback) . '</span>';
	}

	$urlJson = wiki_jobtree_esc(json_encode($urls));
	$html = '<img class="' . $class . '" src="' . wiki_jobtree_esc($urls[0]) . '"';
	$html .= ' alt="' . wiki_jobtree_esc($label) . '" width="72" height="72" loading="lazy"';
	$html .= ' data-sprite-id="' . $jobId . '" data-sprite-urls="' . $urlJson . '">';
	$html .= '<span class="wiki-jobtree-sprite-fallback" hidden>' . wiki_jobtree_esc($fallback) . '</span>';

	return $html;
}

function wiki_render_job_sprites($job)
{
	$ids = wiki_job_sprite_ids($job);
	$name = isset($job['name']) ? $job['name'] : '';

	if (count($ids) > 1) {
		$labels = preg_split('/\s*\/\s*/', $name, 2);
		$labelM = isset($labels[0]) ? $labels[0] : $name;
		$labelF = isset($labels[1]) ? $labels[1] : $name;
		$html = '<div class="wiki-jobtree-sprite-pair">';
		$html .= wiki_render_job_sprite($ids[0], $labelM, 'wiki-jobtree-sprite--male');
		$html .= wiki_render_job_sprite($ids[1], $labelF, 'wiki-jobtree-sprite--female');
		$html .= '</div>';
		return $html;
	}

	if (!empty($ids)) {
		return '<div class="wiki-jobtree-sprite-single">' . wiki_render_job_sprite($ids[0], $name) . '</div>';
	}

	$fallback = mb_substr($name, 0, 1);
	return '<div class="wiki-jobtree-sprite-single"><span class="wiki-jobtree-sprite-fallback">' . wiki_jobtree_esc($fallback) . '</span></div>';
}

function wiki_render_job_card($job, $extraClass = '')
{
	$name = wiki_jobtree_esc($job['name']);
	$comingSoon = wiki_job_is_coming_soon($job);
	$class = 'wiki-jobtree-card' . ($extraClass ? ' ' . $extraClass : '');
	if ($comingSoon) {
		$class .= ' wiki-jobtree-card--soon';
	}

	$html = '<div class="' . $class . '">';
	$html .= wiki_render_job_sprites($job);
	if ($comingSoon) {
		$html .= '<span class="wiki-jobtree-soon-badge">Coming Soon</span>';
	}
	$html .= '<span class="wiki-jobtree-name">' . $name . '</span>';
	$html .= '</div>';

	return $html;
}

function wiki_render_job_chain($chain)
{
	$html = '<div class="wiki-jobtree-chain">';
	$count = count($chain);
	foreach ($chain as $i => $step) {
		$html .= '<div class="wiki-jobtree-chain-step">';
		$html .= '<span class="wiki-jobtree-tier">' . wiki_jobtree_esc($step['tier']) . '</span>';
		$html .= wiki_render_job_card($step);
		$html .= '</div>';
		if ($i < $count - 1) {
			$html .= '<span class="wiki-jobtree-arrow" aria-hidden="true">→</span>';
		}
	}
	$html .= '</div>';
	return $html;
}

function wiki_render_job_branch($branch, $prefix)
{
	$first = $branch['first'];
	$html = '<div class="wiki-jobtree-branch">';
	if (wiki_job_is_coming_soon($first)) {
		$html .= '<div class="wiki-jobtree-branch-soon">Coming Soon</div>';
	}
	$html .= '<div class="wiki-jobtree-first-row">';
	$html .= wiki_render_job_card($first, 'wiki-jobtree-card--first');
	$html .= '<span class="wiki-jobtree-arrow" aria-hidden="true">→</span>';
	$html .= '<div class="wiki-jobtree-seconds">';

	foreach ($branch['paths'] as $path) {
		$pathId = $prefix . '-' . $path['key'];
		$hint = wiki_job_is_coming_soon($path['second']) ? 'Preview path' : 'Click to expand';
		$html .= '<button type="button" class="wiki-jobtree-second-btn" data-jobtree-target="' . wiki_jobtree_esc($pathId) . '" aria-expanded="false">';
		$html .= wiki_render_job_card($path['second'], 'wiki-jobtree-card--second');
		$html .= '<span class="wiki-jobtree-hint">' . wiki_jobtree_esc($hint) . '</span>';
		$html .= '</button>';
	}

	$html .= '</div></div>';

	foreach ($branch['paths'] as $path) {
		$pathId = $prefix . '-' . $path['key'];
		$html .= '<div class="wiki-jobtree-expand" id="' . wiki_jobtree_esc($pathId) . '" hidden>';
		$html .= '<p class="wiki-jobtree-expand-title">Progression: <strong>' . wiki_jobtree_esc($path['second']['name']) . '</strong></p>';
		if (!empty($path['chain'])) {
			$html .= wiki_render_job_chain($path['chain']);
		} else {
			$html .= '<p class="wiki-jobtree-expand-empty">No further job changes in this path — this is the final class for this branch.</p>';
		}
		$dpId = (int) $path['second']['id'];
		if ($dpId > 0 && !wiki_job_is_coming_soon($path['second'])) {
			$html .= '<p class="wiki-jobtree-dp"><a href="https://www.divine-pride.net/database/skilltree/' . $dpId . '" target="_blank" rel="noopener noreferrer">View skills on Divine Pride</a></p>';
		} elseif (wiki_job_is_coming_soon($path['second']) || wiki_job_is_coming_soon($first)) {
			$html .= '<p class="wiki-jobtree-dp wiki-jobtree-dp--soon">This class line is planned for a future update on PRO-Ragnarok.</p>';
		} else {
			$html .= '<p class="wiki-jobtree-dp"><a href="https://www.divine-pride.net/database/skilltree" target="_blank" rel="noopener noreferrer">Browse skills on Divine Pride</a></p>';
		}
		$html .= '</div>';
	}

	$html .= '</div>';
	return $html;
}

function wiki_render_job_tree()
{
	$tree = wiki_get_job_tree();
	$novice = $tree['novice'];

	$html = '<section class="wiki-jobtree" id="wiki-jobtree">';
	$html .= '<h2 id="interactive-job-tree">Interactive Job Tree</h2>';
	$html .= '<p class="wiki-jobtree-intro">Click a <strong>2nd job</strong> portrait to expand Transcendent → 3rd → 4th (or expanded) classes. Job changes are done at the <strong>Job Master</strong> in Prontera (<code>153, 193</code>).</p>';

	$html .= '<div class="wiki-jobtree-novice-block">';
	$html .= wiki_render_job_card($novice, 'wiki-jobtree-card--novice');
	$html .= '<span class="wiki-jobtree-arrow wiki-jobtree-arrow--down" aria-hidden="true">↓</span>';
	$html .= '<div class="wiki-jobtree-sn">';
	$html .= '<p class="wiki-jobtree-sn-label">' . wiki_jobtree_esc($tree['super_novice']['label']) . '</p>';
	$html .= wiki_render_job_chain($tree['super_novice']['chain']);
	$html .= '</div>';
	$html .= '</div>';

	$html .= '<h3 class="wiki-jobtree-heading">Main Classes</h3>';
	$html .= '<div class="wiki-jobtree-grid">';
	foreach ($tree['main'] as $i => $branch) {
		$html .= wiki_render_job_branch($branch, 'main-' . $i);
	}
	$html .= '</div>';

	$html .= '<h3 class="wiki-jobtree-heading">Expanded &amp; Special Classes</h3>';
	$html .= '<div class="wiki-jobtree-grid wiki-jobtree-grid--expanded">';
	foreach ($tree['expanded'] as $i => $branch) {
		$html .= wiki_render_job_branch($branch, 'exp-' . $i);
	}
	$html .= '</div>';

	if (!empty($tree['coming_soon'])) {
		$html .= '<h3 class="wiki-jobtree-heading">New Classes</h3>';
		$html .= '<div class="wiki-jobtree-grid wiki-jobtree-grid--soon">';
		foreach ($tree['coming_soon'] as $i => $branch) {
			$html .= wiki_render_job_branch($branch, 'soon-' . $i);
		}
		$html .= '</div>';
	}

	$html .= '<p class="wiki-jobtree-note"><strong>Baby classes</strong> mirror the same trees with Baby variants (enabled on this server). <strong>Gender split:</strong> Bard→Clown→Minstrel→Troubadour (M); Dancer→Gypsy→Wanderer→Trouvere (F). <strong>Druid</strong> (Episode 21) is shown above as <em>Coming Soon</em>.</p>';
	$html .= '</section>';

	return $html;
}
