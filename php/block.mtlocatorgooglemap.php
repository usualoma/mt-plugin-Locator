<?php
function smarty_block_MTLocatorGoogleMap($args, $content, &$ctx, &$repeat) {
	$localvars = array('locator_google_map_of');
	$localvarvars = array('locator_script_loaded');
	if (! isset($content)) {
		$ctx->localize($localvars, $localvarvars);

        if (isset($args['load_script'])) {
            $ctx->__stash['vars']['locator_script_loaded'] = $args['load_script'];
        }

		if ($args['of']) {
			$ctx->__stash['locator_google_map_of'] = $args['of'];
		}

        $ctx->__stash['vars']['LocatorMapTypeControl'] =
            isset($args['map_type_control']) ? $args['map_type_control'] : 'true';
        $ctx->__stash['vars']['LocatorPanControl'] =
            isset($args['pan_control']) ? $args['pan_control'] : 'true';
        $ctx->__stash['vars']['LocatorZoomControl'] =
            isset($args['zoom_control']) ? $args['zoom_control'] : 'true';
        $ctx->__stash['vars']['LocatorScaleControl'] =
            isset($args['scale_control']) ? $args['scale_control'] : 'true';
        $ctx->__stash['vars']['LocatorStreetViewControl'] =
            isset($args['street_view_control']) ? $args['street_view_control'] : 'true';

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
		|| ! $loc->latitude_g
		|| ! $loc->longitude_g
	) {
		return '';
	}

	if (!$repeat) {
		$ctx->restore($localvars, $localvarvars);
        $ctx->__stash['vars']['locator_script_loaded'] = 1;
    }

	return $content;
}
?>
