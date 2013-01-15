<?php
function smarty_function_MTLocatorGoogleMapMobile($args, &$ctx) {
	$loc = locator_detect_location($args, $ctx);
	if (
		empty($loc)
		|| ! $loc->latitude_g
		|| ! $loc->longitude_g
	) {
		return '';
	}

	$lat = $loc->latitude_g;
	$lng = $loc->longitude_g;

    $blog_id = $ctx->stash('blog_id');
	$client_id = locator_fetch_plugin_config_value(
		'googlemap_client_id', 'blog:' . $blog_id
	);
	if (! $client_id) {
		$client_id = locator_fetch_plugin_config_value('googlemap_client_id');
	}
	$crypto_key = locator_fetch_plugin_config_value(
		'googlemap_crypto_key', 'blog:' . $blog_id
	);
	if (! $crypto_key) {
		$crypto_key = locator_fetch_plugin_config_value('googlemap_crypto_key');
	}

	$zoom = isset($args['zoom']) ? $args['zoom'] : '';
	if (! $zoom) {
		$zoom = $ctx->stash('locator_zoom');
	}
	if (! $zoom) {
		$zoom = $loc->zoom_g;
	}
	if (! $zoom) {
		$zoom = 10;
	}

	$width = isset($args['width']) ? $args['width'] : '200';
	$height = isset($args['height']) ? $args['height'] : '200';

    $maptype = isset($args['maptype']) ? $args['maptype'] : 'roadmap';
    $protocol = isset($args['protocol']) ? $args['protocol'] : 'http';

    $portion_to_sign =
        '/maps/api/staticmap?' .
        'sensor=false' .
        ($client_id ? ('&client=' . $client_id) : '') .
        '&center=' . $lat . ',' . $lng .
        '&zoom=' . $zoom .
        '&size=' . $width . 'x' . $height .
        '&maptype=' . $maptype .
        '&markers=' . $lat . ',' . $lng;

	if ($args['id']) {
		$portion_to_sign .= ' id="' . $args['id'] . '"';
	}
	if ($args['class']) {
		$portion_to_sign .= ' class="' . $args['class'] . '"';
	}
	if ($args['style']) {
		$portion_to_sign .= ' style="' . $args['style'] . '"';
	}

    $sign = '';
    if ($crypto_key) {
        $sign = '&signature=' . hash_hmac('sha1', $portion_to_sign, $crypto_key);
    }

    return '<img src="' . $protocol . '://maps.google.com' .
        $portion_to_sign . $sign . '" />';
}
?>
