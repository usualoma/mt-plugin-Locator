<?php
function smarty_function_MTGoogleMapCryptoKey($args, &$ctx) {
    $blog_id = $ctx->stash('blog_id');
	$key = locator_fetch_plugin_config_value(
		'googlemap_crypto_key', 'blog:' . $blog_id
	);
	if (! $key) {
		$key = locator_fetch_plugin_config_value('googlemap_crypto_key');
	}
	return $key;
}
?>
