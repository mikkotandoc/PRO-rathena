<?php
/**
 * PRO-Ragnarok Wiki — FluxCP addon configuration.
 * Merged into config/application.php on load.
 */
return array(
	'WikiSiteName' => 'PRO-Ragnarok Wiki',
	'WikiTagline'  => 'Player wiki for Cathode — PRO-Ragnarok private server',

	'MenuItems' => array(
		'MainMenuLabel' => array(
			'WikiLabel' => array('module' => 'wiki'),
		),
	),

	'SubMenuItems' => array(
		'wiki' => array(
			'index' => 'Wiki Home',
		),
	),
);
