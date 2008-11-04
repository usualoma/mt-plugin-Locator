<?php
function smarty_function_MTLocatorAddress($args, &$ctx) {
	$loc = locator_detect_location($args, $ctx);
	if (empty($loc)) {
		return '';
	}

	if ($addr = $ctx->stash('locator_address')) {
		return $addr;
	}
	else if ($addr = $loc['location_address']) {
		return $addr;
	}
	else {
		return '';
	}
}
?>
