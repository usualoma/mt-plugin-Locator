<?php
function smarty_function_MTLocatorZoom($args, &$ctx) {
	$loc = locator_detect_location($args, $ctx);
	if (empty($loc)) {
		return '';
	}

	if ((! $ctx->stash('locator_longitude')) && (! $loc['location_longitude_g'])) {
		return '';
	}
	else if ($value = $ctx->stash('locator_zoom')) {
		return $value;
	}
	else if ($value = $loc['location_zoom_g']) {
		return $value;
	}
	else {
		return '';
	}
}
?>
