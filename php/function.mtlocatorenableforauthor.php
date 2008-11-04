<?php
function smarty_function_MTLocatorEnableForAuthor($args, &$ctx) {
	return locator_fetch_plugin_config_value(
		'enable_for_author', null, '0'
	);
}
?>
