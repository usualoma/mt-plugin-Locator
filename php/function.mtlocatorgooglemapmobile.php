<?php
function smarty_function_MTLocatorGoogleMapMobile($args, &$ctx) {
	$loc = locator_detect_location($args, $ctx);
	if (
		empty($loc)
		|| empty($loc['location_latitude_g'])
		|| empty($loc['location_longitude_g'])
	) {
		return '';
	}

	$lat = $loc['location_latitude_g'];
	$lng = $loc['location_longitude_g'];

    $blog_id = $ctx->stash('blog_id');
	$key = locator_fetch_plugin_config_value(
		'googlemap_api_key', 'blog:' . $blog_id
	);
	if (! $key) {
		$key = locator_fetch_plugin_config_value('googlemap_api_key');
	}

	$zoom = isset($args['zoom']) ? $args['zoom'] : '';
	if (! $zoom) {
		$zoom = $ctx->stash('locator_zoom');
	}
	if (! $zoom) {
		$zoom = $loc['location_zoom_g'];
	}
	if (! $zoom) {
		$zoom = 10;
	}

	$width = isset($args['width']) ? $args['width'] : '200';
	$height = isset($args['height']) ? $args['height'] : '200';

	$img = '<img src="' .
	'http://maps.google.com/staticmap?center=' . $lat . ',' . $lng .
	'&zoom=' . $zoom .
    '&size=' . $width . 'x' . $height .
    '&maptype=mobile' .
    '&key=' . $key .
	'"';

	if ($args['id']) {
		$img .= ' id="' . $args['id'] . '"';
	}
	if ($args['class']) {
		$img .= ' class="' . $args['class'] . '"';
	}
	if ($args['style']) {
		$img .= ' style="' . $args['style'] . '"';
	}

	$img .= '/>';

	return $img;
}
?>
