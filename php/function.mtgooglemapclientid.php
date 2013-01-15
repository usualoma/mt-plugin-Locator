<?php
function smarty_function_MTGoogleMapClientID($args, &$ctx) {
    $blog_id = $ctx->stash('blog_id');
	$key = locator_fetch_plugin_config_value(
		'googlemap_client_id', 'blog:' . $blog_id
	);
	if (! $key) {
		$key = locator_fetch_plugin_config_value('googlemap_client_id');
	}
	return $key;
}
?>
