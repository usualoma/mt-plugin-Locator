<?php

function locator_fetch_plugin_config($scope = 'system') {
	static $configs = array();
	if ($configs[$scope]) {
		return $configs[$scope];
	}

	global $mt;
	$configs[$scope] = $mt->db->fetch_plugin_config('Locator', $scope);

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

function locator_fetch_location($args) {
	global $mt;
	$db =& $mt->db;

	$where = array();
	foreach (array('entry', 'blog', 'author') as $k) {
		if (! empty($args[$k . '_id'])) {
			$where[] = 'location_' . $k . '_id = ' . $args[$k . '_id'];
		}
	}

	$sql = 'SELECT * FROM mt_location WHERE 1 AND ' . join(' AND ', $where);
	$res = $db->get_results($sql, ARRAY_A);
	return $res;
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
			$loc = locator_fetch_location(array('entry_id' => $entry['entry_id']));
			if (! $loc) {
				return null;
			}
			return $loc[0];
		}

		if ($for == 'entry') {
			return null;
		}
	}

	if ((! $for) || ($for == 'blog')) {
		$blog_id = $ctx->stash('blog_id');
		if ($blog_id) {
			$loc = locator_fetch_location(array('blog_id' => $blog_id));
			if (! $loc) {
				return null;
			}
			return $loc[0];
		}

		if ($for == 'blog') {
			return null;
		}
	}

	$author = $ctx->stash('author');
	if ($author) {
		$loc = locator_fetch_location(array('author_id' => $author['author_id']));
		if (! $loc) {
			return null;
		}
		return $loc[0];
	}
	else {
		return null;
	}
}

?>
