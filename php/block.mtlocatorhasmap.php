<?php
function smarty_block_MTLocatorHasMap($args, $content, &$ctx, &$repeat) {
	$loc = locator_detect_location($args, $ctx);
	if (
		empty($loc)
		|| ! $loc->latitude_g
		|| ! $loc->longitude_g
	) {
		return '';
	}

	return $content;
}
?>
