<?php
function smarty_block_MTLocatorGoogleMap($args, $content, &$ctx, &$repeat) {
	$localvars = array('locator_google_map_of');
	if (! isset($content)) {
		$ctx->localize($localvars);
		if ($args['of']) {
			$ctx->__stash['locator_google_map_of'] = $args['of'];
		}

		$map_control = 'GLargeMapControl';
		if (isset($args['map_control'])) {
			$map_control = $args['map_control'];
		}
		$ctx->__stash['vars']['LocatorMapControl'] = $map_control;

		$ctx->__stash['vars']['LocatorMapID'] =
			isset($args['id']) ? $args['id'] : 'locator_map';
		$ctx->__stash['vars']['LocatorMapClass'] =
			isset($args['class']) ? $args['class'] : '';
		$ctx->__stash['vars']['LocatorMapStyle'] = '';
		isset($args['style']) ? $args['style'] : '';

		$ctx->__stash['vars']['LocatorMapWidth'] =
			preg_replace(
				'/(\d)$/', '$1px', isset($args['width']) ? $args['width'] : '400'
			);
		$ctx->__stash['vars']['LocatorMapHeight'] =
			preg_replace(
				'/(\d)$/', '$1px', isset($args['height']) ? $args['height'] : '400'
			);

		if (isset($args['zoom'])) {
			$ctx->__stash['locator_zoom'] = $args['zoom'];
		}
	}
	else {
		$ctx->__stash['vars']['LocatorInfoWindow'] = $content;
		$map_tmpl =
			dirname(dirname(__FILE__)) . DIRECTORY_SEPARATOR
			. 'tmpl' . DIRECTORY_SEPARATOR
			. 'tag_google_map.tmpl';
		$string = str_replace(
			'<MT_TRANS phrase="Location default zoomlevel">',
			'10',
			join('', file($map_tmpl))
		);
		if ($ctx->_compile_source('evaluated template', $string, $_var_compiled)) {
			ob_start();
			$ctx->_eval('?>' . $_var_compiled);
			$content = ob_get_contents();
			ob_end_clean();
		}
		else {
			'';
		}
	}

	$loc = locator_detect_location($args, $ctx);
	if (
		empty($loc)
		|| empty($loc['location_latitude_g'])
		|| empty($loc['location_longitude_g'])
	) {
		return '';
	}

	if (!$repeat)
		$ctx->restore($localvars);

	return $content;
}
?>
