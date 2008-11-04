<?php
function smarty_function_MTGoogleMapAPIKey($args, &$ctx) {
    $blog_id = $ctx->stash('blog_id');
	$key = locator_fetch_plugin_config_value(
		'googlemap_api_key', 'blog:' . $blog_id
	);
	if (! $key) {
		$key = locator_fetch_plugin_config_value('googlemap_api_key');
	}
	return $key;
}
?>
