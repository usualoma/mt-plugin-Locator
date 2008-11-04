<?php
function smarty_function_MTLocatorEnableForBlog($args, &$ctx) {
	return locator_fetch_plugin_config_value(
		'enable_for_blog', null, '0'
	);
}
?>
