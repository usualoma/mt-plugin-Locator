<?php
function smarty_function_MTLocatorEnableForPage($args, &$ctx) {
    $blog_id = $ctx->stash('blog_id');
	return locator_fetch_plugin_config_value(
		'enable_for_page', 'blog:' . $blog_id, '0'
	);
}
?>
