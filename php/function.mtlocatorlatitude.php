<?php
function smarty_function_MTLocatorLatitude($args, &$ctx) {
	$loc = locator_detect_location($args, $ctx);
	if (empty($loc)) {
		return '';
	}

	if ($value = $ctx->stash('locator_latitude')) {
		return $value;
	}
	else if ($value = $loc->latitude_g) {
		return $value;
	}
	else {
		return '';
	}
}
?>
