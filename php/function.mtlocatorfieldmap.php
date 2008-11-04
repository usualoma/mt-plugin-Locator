<?php
function smarty_function_MTLocatorFieldMap($args, &$ctx) {
	return locator_fetch_plugin_config_value('field_map');
}
?>
