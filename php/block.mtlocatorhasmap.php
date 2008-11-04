<?php
function smarty_block_MTLocatorHasMap($args, $content, &$ctx, &$repeat) {
	$loc = locator_detect_location($args, $ctx);
	if (
		empty($loc)
		|| empty($loc['location_latitude_g'])
		|| empty($loc['location_longitude_g'])
	) {
		return '';
	}

	return $content;
}
?>
