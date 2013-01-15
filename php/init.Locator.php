<?php

function locator_fetch_plugin_config($scope = 'system') {
	static $configs = array();
	if ($configs[$scope]) {
		return $configs[$scope];
	}

	global $mt;
	$configs[$scope] = $mt->db()->fetch_plugin_config('Locator', $scope);

	return $configs[$scope];
}

function locator_fetch_plugin_config_value(
	$name, $scope = null, $default = ''
) {
	if (! $scope) {
		$scope = 'system';
	}
	$config = locator_fetch_plugin_config($scope);
	if (empty($config) || empty($config[$name])) {
		return $default;
	}
	else {
		return $config[$name];
	}
}

function set_locator_column($obj) {
    foreach (array('latitude_g', 'longitude_g', 'zoom_g', 'address') as $k) {
        $k_with_p = $obj->_prefix . $k;
        $obj->$k = $obj->$k_with_p;
    }

    return $obj;
}

function locator_detect_location(&$args, &$ctx) {
	$for = $args['of'];
	if (! $for) {
		$for = $ctx->stash('locator_google_map_of');
	}
	if (! $for) {
	   	$for = '';
	}

	if ((! $for) || ($for == 'entry')) {
		$entry = $ctx->stash('entry');
		if ($entry) {
            return set_locator_column($entry);
		}
		else if ($for == 'entry') {
			return null;
		}
	}

	if ((! $for) || ($for == 'blog')) {
		$blog = $ctx->stash('blog');
		if ($blog) {
            return set_locator_column($blog);
		}
		else if ($for == 'blog') {
			return null;
		}
	}

	$author = $ctx->stash('author');
	if ($author) {
		return set_locator_column($author);
	}
	else {
		return null;
	}
}

?>
