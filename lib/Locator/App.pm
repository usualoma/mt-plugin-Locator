#   Copyright (c) 2008 ToI-Planning, All rights reserved.
# 
#   Redistribution and use in source and binary forms, with or without
#   modification, are permitted provided that the following conditions
#   are met:
# 
#   1. Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#
#   2. Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#
#   3. Neither the name of the authors nor the names of its contributors
#      may be used to endorse or promote products derived from this
#      software without specific prior written permission.
#
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
#   OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
#   TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
#   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
#   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
#   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#  $Id$

package Locator::App;
use strict;
use File::Basename;

sub pre_save{
	my ($plugin, $cb, $obj, $original) = @_;
	my $app = MT->instance;
	my $datasource = $obj->datasource;

	return if !($app->can('param')); # God knows where we'll be coming from!

	return if !($app->param('locator_beacon'));

	my $blog_id = $app->param('blog_id');
	my $scope = $blog_id ? ('blog:' . $blog_id) : 'system';
	if ($datasource ne 'entry') {
		$scope = undef;
	}

	my $enabled = $plugin->get_config_value(
		'enable_for_' . $datasource, $scope
	);
	if (! $enabled) {
		return;
	}
	
	my $field_address = $plugin->get_config_value('field_address');
	my $field_map = $plugin->get_config_value('field_map');

	if (($field_address >= 2) && (! $app->param('location_address'))) {
		$app->send_http_header;
		$app->print($app->show_error($plugin->translate('Please ensure address fields have been filled in.')));
		$app->{no_print_body} = 1;
		exit();
	}
	if (($field_map >= 2) && ((! $app->param('location_latitude_g')) || ! $app->param('location_longitude_g'))) {
		$app->send_http_header;
		$app->print($app->show_error($plugin->translate('Please ensure map fields have been filled in.')));
		$app->{no_print_body} = 1;
		exit();
	}

	if (MT->version_number >= 5) {
		&save_data(@_);
	}
}

sub post_save {
	my ($plugin, $cb, $obj, $original) = @_;
	my $app = MT->instance;

	return if !($app->can('param')); # God knows where we'll be coming from!

	return if !($app->param('locator_beacon'));

	if (MT->version_number < 5) {
		&save_data(@_);
	}
}

sub save_data {
	my ($plugin, $cb, $obj, $original) = @_;
	my $app = MT->instance;

	return if !($app->can('param')); # God knows where we'll be coming from!

	return if !($app->param('locator_beacon'));

	my $q = $app->{query};
	my $blog_id = $q->param('blog_id');
	my $datasource = $obj->datasource;

	my $scope = $blog_id ? ('blog:' . $blog_id) : 'system';
	if ($datasource ne 'entry') {
		$scope = undef;
	}

	require UNIVERSAL;
	if (UNIVERSAL::isa($obj, 'MT::Blog')) {
		if (
			(! $blog_id)
			&& ((! $original) || (! $original->id))
		) {
			$plugin->set_config_value(
				'enable_for_entry',
				$plugin->get_config_value('enable_for_entry', 'system'),
				'blog:' . $obj->id
			);
		}
	}

	my $enabled = $plugin->get_config_value(
		'enable_for_' . $datasource, $scope
	);
	if (! $enabled) {
		return;
	}
	
	my $field_address = $plugin->get_config_value('field_address');
	my $field_map = $plugin->get_config_value('field_map');

	require Locator::Location;
	my $id_field = $datasource . '_id';
	if (
		($datasource eq 'blog') && ($app->param('_type') ne 'blog')
	) {
		return;
	}

	my $loc = $obj;
	if (MT->version_number < 5) {
		$loc = Locator::Location->load({$id_field => $obj->id});
		if (! $loc) {
			$loc = Locator::Location->new;
			$loc->blog_id(0);
			$loc->author_id(0);
			$loc->entry_id(0);
			$loc->$id_field($obj->id);
		}
	}

	if ($field_address) {
		$loc->address($q->param('location_address'));
	}
	else {
		$loc->address('');
	}

	if ($field_map) {
		$loc->latitude_g($q->param('location_latitude_g'));
		$loc->longitude_g($q->param('location_longitude_g'));
		$loc->zoom_g($q->param('location_zoom_g') || 0);
	}
	else {
		$loc->latitude_g('');
		$loc->longitude_g('');
		$loc->zoom_g(0);
	}

	if (MT->version_number < 5) {
		$loc->save or die $loc->errstr;
	}
}

sub _field_loop_param {
	my($plugin, $cb, $app, $param, $tmpl) = @_;
	my $q = $app->param;
	my $blog_id = $q->param('blog_id');
	my $datasource = $q->param('_type');
	my $id = $q->param('id') || ($datasource eq 'author' ? $q->param('author_id') : '');
	my $perms = $app->{perms};

	if ($datasource eq 'page') {
		$datasource = 'entry';
	}

	{
		my $found = 0;
		foreach my $key ('address', 'latitude_g', 'longitude_g', 'zoom_g') {
			if ($param->{$key}) {
				$found = 1;
				$param->{'location_' . $key} = $param->{$key};
			}
		}
		return if $found;
	}

	my $data;
	if (MT->version_number >= 5) {
		my $class = MT->model($q->param('_type'));
		$data = $class->load($id);
	}
	else {
		if ($id) {
			require Locator::Location;
			$data = Locator::Location->load({$datasource . '_id' => $id});
		}
	}

	foreach my $key ('address', 'latitude_g', 'longitude_g', 'zoom_g') {
		$param->{'location_' . $key} = $data ? $data->$key : '';
	}
	$param->{'location_google_map_api_key'} = $plugin->get_config_value(
		'googlemap_api_key'
	);
}

sub _edit_map_author_tmpl {
	my $plugin = shift;
	my $version = MT->version_number;
	if ($version < 5) {
		File::Spec->catdir($plugin->{full_path},'tmpl','edit_map_author_4.tmpl');
	}
	else {
		File::Spec->catdir($plugin->{full_path},'tmpl','edit_map_author.tmpl');
	}
}

sub _edit_blog {
	my ($plugin, $cb, $app, $tmpl) = @_;
	my ($old, $new);

	my $enabled = $plugin->get_config_value('enable_for_blog');
	if (! $enabled) {
		return;
	}
	
	#_add_defaults($plugin, $app, $tmpl);

	my $edit_map_tmpl = &_edit_map_author_tmpl($plugin);
	
	$old = '<mt:setvarblock name="action_buttons">';
#	$old = quotemeta($old);
	$new = $plugin->load_tmpl_translated($edit_map_tmpl);

	$$tmpl =~ s/($old)/$new\n$1\n/;
}

sub _edit_entry {
	my ($plugin, $cb, $app, $tmpl) = @_;
	my $blog_id = $app->param('blog_id');
	my ($old, $new);

	my $enabled = $plugin->get_config_value(
		'enable_for_entry', 'blog:' . $blog_id
	);
	if (! $enabled) {
		return;
	}
	
	#_add_defaults($plugin, $app, $tmpl);

	my $version = MT->version_number;
	if ($version >= 4 ) {
		my $edit_map_tmpl = File::Spec->catdir($plugin->{full_path},'tmpl','edit_map_entry.tmpl');
		if ($version < 5) {
			$edit_map_tmpl = File::Spec->catdir($plugin->{full_path},'tmpl','edit_map_entry_4.tmpl');
		}

		my $placement =
			$plugin->get_config_value('entry_placement', 'system')
			|| $plugin->get_config_value('entry_placement', 'blog:' . $blog_id)
			|| 1;
		$old = (
			'(<mt:include name="include/editor.tmpl">)()',
			'()(<mt:include\s*name="include/actions_bar.tmpl"\s*bar_position="bottom")',
		)[$placement-1];

	#	$old = quotemeta($old);
		$new = $plugin->load_tmpl_translated($edit_map_tmpl);

		$$tmpl =~ s/$old/$1\n$new\n$2/;
	}
	else {
		my $edit_map_tmpl = File::Spec->catdir($plugin->{full_path},'tmpl','edit_map_entry_33.tmpl');
		
		$old = '<TMPL_IF NAME=POSITION_BUTTONS_BOTTOM>';
		$new = $plugin->load_tmpl_translated($edit_map_tmpl);

		$$tmpl =~ s/($old)/$new\n$1\n/;
	}
}

sub _edit_author {
	my ($plugin, $cb, $app, $tmpl) = @_;
	my ($old, $old2, $new);

	my $enabled = $plugin->get_config_value('enable_for_author');
	if (! $enabled) {
		return;
	}
	
	#_add_defaults($plugin, $app, $tmpl);

	my $edit_map_tmpl = &_edit_map_author_tmpl($plugin);
	
	$old = '<fieldset>[\s\n]*<h3><__trans phrase="Preferences"></h3>';
	$old2 = '<h3><__trans phrase="New User Defaults"></h3>';
#	$old = quotemeta($old);
	$new = $plugin->load_tmpl_translated($edit_map_tmpl);

	$$tmpl =~ s/($old|$old2)/$new\n$1\n/;
}

1;
