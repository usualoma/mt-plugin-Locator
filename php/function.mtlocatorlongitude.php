<?php
function smarty_function_MTLocatorLongitude($args, &$ctx) {
	$loc = locator_detect_location($args, $ctx);
	if (empty($loc)) {
		return '';
	}

	if ($value = $ctx->stash('locator_longitude')) {
		return $value;
	}
	else if ($value = $loc->longitude_g) {
		return $value;
	}
	else {
		return '';
	}
}
?>
