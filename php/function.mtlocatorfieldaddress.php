<?php
function smarty_function_MTLocatorFieldAddress($args, &$ctx) {
	return locator_fetch_plugin_config_value('field_address');
}
?>
