<?php
function smarty_function_MTLocatorEnableForEntry($args, &$ctx) {
    $blog_id = $ctx->stash('blog_id');
	return locator_fetch_plugin_config_value(
		'enable_for_entry', 'blog:' . $blog_id, '0'
	);
}
?>
