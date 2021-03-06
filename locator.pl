# locator.pl
#
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

package MT::Plugin::Locator;

use 5.006;    # requires Perl 5.6.x
use MT 3.3;   # requires MT 3.3 or later

use base 'MT::Plugin';
our $VERSION = '1.0.9';
our $SCHEMA_VERSION = '0.73';

my $plugin;
MT->add_plugin($plugin = __PACKAGE__->new({
	id              => "Locator",
	name            => "Locator",
	version         => $VERSION,
	schema_version  => $SCHEMA_VERSION,
	description     => "<MT_TRANS phrase=\"location ties to the author/blog/entry.\">",
	author_name     => "<MT_TRANS phrase=\"toi-planning\">",
	author_link     => "http://tec.toi-planning.net/",
	plugin_link     => "http://tec.toi-planning.net/mt/locator/",
	doc_link        => "http://tec.toi-planning.net/mt/locator/manual",
	object_classes  => [ 'Locator::Location' ],
	settings => new MT::PluginSettings([
		['field_address', {Default => 2}],
		['field_map', {Default => 2}],
		['field_zoom', {Default => 1}],
		['show_latlng', {Default => 0}],
		['show_zoom', {Default => 0}],

		['enable_for_author', {Default => 1}],
		['enable_for_blog', {Default => 1}],
		['enable_for_page', {Default => 1}],
		['enable_for_entry', {Default => 1}],

		['googlemap_api_key'],
		['googlemap_client_id'],
		['googlemap_crypto_key'],

		['entry_placement', {Default => 1}],
	]),
    config_settings => {
        LocatorIsPremier => {
            default => 0,
        },
    },
	system_config_template =>
		(MT->version_number >= 4 ) ?
			'locator_system_config.tmpl' : 'locator_system_config_33.tmpl',
	blog_config_template =>
		(MT->version_number >= 4 ) ?
			'locator_blog_config.tmpl' : 'locator_blog_config_33.tmpl',
	callbacks => {
        'MT::App::CMS::cms_pre_preview' => sub { runner('cms_pre_preview', 'app', @_); },
        (   map {
                my $type = $_;
                (   "MT::App::CMS::cms_pre_save.$type" =>
                        sub { runner( 'cms_pre_save', 'app', $type, @_ ); }
                    )
                } qw(entry page)
            ),
        (   map {
                my $type = $_;
                (   "MT::App::CMS::cms_save_filter.$type" =>
                        sub { runner( 'cms_save_filter', 'app', $type, @_ ); }
                    )
                } qw(entry page author blog)
            ),

		'MT::App::CMS::template_param.edit_author' => sub { runner('_field_loop_param', 'app', @_); },
		'MT::App::CMS::template_source.edit_author' => sub { runner('_edit_author', 'app', @_); },	
		'MT::Author::pre_save' => sub { runner('pre_save', 'app', @_); },	
		'MT::Author::post_save' => sub { runner('post_save', 'app', @_); },		

		'MT::App::CMS::template_param.edit_entry' => sub { runner('_field_loop_param', 'app', @_); },
		'MT::App::CMS::template_source.edit_entry' => {
			code => sub { runner('_edit_entry', 'app', @_); },
			priority => 10
		}, 
		'MT::Entry::pre_save' => sub { runner('pre_save', 'app', @_); },
		'MT::Entry::post_save' => sub { runner('post_save', 'app', @_); },

		'MT::Page::pre_save' => sub { runner('pre_save', 'app', @_); },
		'MT::Page::post_save' => sub { runner('post_save', 'app', @_); },

		'MT::App::CMS::template_param.edit_blog' => sub { runner('_field_loop_param', 'app', @_); },
		'MT::App::CMS::template_param.cfg_prefs' => sub { runner('_field_loop_param', 'app', @_); },
		'MT::App::CMS::template_source.edit_blog' => sub { runner('_edit_blog', 'app', @_); },	
		'MT::App::CMS::template_source.cfg_prefs' => sub { runner('_edit_blog', 'app', @_); },	
		'MT::Blog::pre_save' => sub { runner('pre_save', 'app', @_); },
		'MT::Blog::post_save' => sub { runner('post_save', 'app', @_); },
	},
	l10n_class  => 'Locator::L10N',
}));

BEGIN {
	our $template_tags = {
		'LocatorFieldAddress' => '_hdlr_locator_field',
		'LocatorFieldMap' => '_hdlr_locator_field',
		'LocatorFieldZoom' => '_hdlr_locator_field',

		'LocatorEnableForAuthor' => '_hdlr_locator_enable_for',
		'LocatorEnableForBlog' => '_hdlr_locator_enable_for',
		'LocatorEnableForEntry' => '_hdlr_locator_enable_for',
		'LocatorEnableForPage' => '_hdlr_locator_enable_for',

		'GoogleMapAPIKey' => '_hdlr_googlemap_api_key',
		'GoogleMapClientID' => '_hdlr_googlemap_client_id',
		'GoogleMapCryptoKey' => '_hdlr_googlemap_crypto_key',

		'LocatorGoogleMapMobile' => '_hdlr_locator_google_map_mobile',

		'LocatorLatitude' => '_hdlr_locator_latitude_g',
		'LocatorLongitude' => '_hdlr_locator_longitude_g',
		'LocatorZoom' => '_hdlr_locator_zoom_g',
		'LocatorAddress' => '_hdlr_locator_address',
	};
	our $template_container_tags = {
		'LocatorHasMap?' => '_hdlr_locator_has_map',
		'LocatorGoogleMap' => '_hdlr_locator_google_map',
		'LocatorIsPremier?' => '_hdlr_locator_is_premier',

		'LocatorNearestEntries' => '_hdlr_locator_nearest_entries',
	};
}

sub init_registry { 
	my $plugin = shift;
	my $hash = {
		tags => {
			help_url => 'http://tec.toi-planning.net/mt/locator/tags#%t',
			function => {},
			block => {},
		}
	};

	foreach my $key (keys(%$template_tags)) {
		$hash->{tags}->{function}->{$key} = sub {
			runner($template_tags->{$key}, 'template', @_);
		};
	}

	foreach my $key (keys(%$template_container_tags)) {
		$hash->{tags}->{block}->{$key} = sub {
			runner($template_container_tags->{$key}, 'template', @_);
		};
	}

	if (MT->version_number >= 5) {
		my $types = {
			'address' => {
				type => 'string',
				size => 255,
				not_null => 0,
				revisioned => 1,
			},
			'zoom_g' => {
				type => 'smallint',
				not_null => 0,
				revisioned => 1,
			},
			'latitude_g' => {
				type => 'string',
				size => 255,
				not_null => 0,
				revisioned => 1,
			},
			'longitude_g' => {
				type => 'string',
				size => 255,
				not_null => 0,
				revisioned => 1,
			},
		};
		$hash->{object_classes} = [];
		$hash->{object_types} = {
			'entry' => $types,
			'blog' => $types,
			'author' => $types,
		};
	}

	require MT;
	my $app = MT->instance;
	if ($app->isa('MT::App::Upgrader')) {
		if (MT->version_number >= 5) {
			$plugin->registry($hash);
		}
	}
	else {
		$plugin->registry($hash);
	}
}

sub init_app {
	my $app = shift;
	if (MT->version_number >= 5) {
		if(! $app->isa('MT::App::Upgrader')) {
			no warnings 'redefine';
			my $load = \&MT::BasicAuthor::load;
			*MT::BasicAuthor::load = sub {
				$_[2] ||= {};
				$_[2]->{'fetchonly'} = [
					'id', 'name', 'nickname', 'password', 'type', 'email', 'url',
					'public_key', 'preferred_language', 'api_password',
					'remote_auth_username', 'remote_auth_token', 'entry_prefs',
					'text_format', 'status', 'external_id',
				];

				MT::Object::load(@_);
			};
		}
	}
}

if (MT->version_number < 4 ) {
	&{sub{
		require MT::Template::Context;
		my ($hash) = @_;
		foreach my $key (keys(%$hash)) {
			MT::Template::Context->add_tag(
				$key => sub { runner($hash->{$key}, 'template', @_); }
			);
		}
	}}($template_tags);

	&{sub{
		require MT::Template::Context;
		my ($hash) = @_;
		foreach my $key (keys(%$hash)) {
			MT::Template::Context->add_container_tag(
				$key => sub { runner($hash->{$key}, 'template', @_); }
			);
		}
	}}($template_container_tags);

	require MT;
    MT->add_callback(
		'*::AppTemplateSource.edit_entry', 10, $plugin,
		sub { runner('_edit_entry', 'app', @_); }
	);
    MT->add_callback(
		'*::AppTemplateParam.edit_entry', 10, $plugin,
		sub { runner('_field_loop_param', 'app', @_); }
	);
    require MT::Entry;
    MT::Entry->add_callback(
		'pre_save', 10, $plugin, sub { runner('pre_save', 'app', @_); }
	);
    MT::Entry->add_callback(
		'post_load', 10, $plugin, sub { runner('post_save', 'app', @_); }
	);
}

# Allows external access to plugin object: MT::Plugin::Locator->instance
sub instance { $plugin; }

# Corrects bug in MT 3.31/2 <http://groups.yahoo.com/group/mt-dev/message/962>
sub init {
	my $plugin = shift;
	$plugin->SUPER::init(@_);
	MT->config->PluginSchemaVersion({})
	unless MT->config->PluginSchemaVersion;
}

sub save_config {
	my $plugin = shift;
	my ($args, $scope) = @_;

	$plugin->SUPER::save_config(@_);

	my ($blog_id);
	if ( $scope =~ /blog:(\d+)/ ) {
		return;
	}
	else {
		require MT::Blog;
		my @blogs = MT::Blog->load({class => '*'});
		foreach my $b (@blogs) {
			my $enable_for_entry;
			if ($args->{'enable_for_entry_' . $b->id}) {
				$enable_for_entry = $args->{enable_for_entry} && 1;
			}
			else {
				$enable_for_entry = 0;
			}

			if (MT->version_number < 4 ) {
				#always enabled
				$enable_for_entry = 1;
			}
			
			$plugin->set_config_value(
				'enable_for_entry', $enable_for_entry, 'blog:' . $b->id
			);


			my $enable_for_page;
			if ($args->{'enable_for_page_' . $b->id}) {
				$enable_for_page = $args->{enable_for_page} && 1;
			}
			else {
				$enable_for_page = 0;
			}

			if (MT->version_number < 4 ) {
				#always enabled
				$enable_for_page = 1;
			}

			$plugin->set_config_value(
				'enable_for_page', $enable_for_page, 'blog:' . $b->id
			);
		}
	}
}

sub runner {
    my $method = shift;
	my $class = shift;
	if($class eq 'app') {
		$class = 'Locator::App';
	} elsif($class eq 'template') {
		$class = 'Locator::Template::ContextHandlers';
	}
    eval "require $class;";
    if ($@) { die $@; $@ = undef; return 1; }
    my $method_ref = $class->can($method);
    return $method_ref->($plugin, @_) if $method_ref;
    die $plugin->translate("Failed to find [_1]::[_2]", $class, $method);
}

sub load_tmpl_translated {
	my ($plugin, $file) = @_;
	open(my $fh, $file);
	$plugin->translate_templatized( do{ local $/; <$fh> } );
}

sub is_empty {
	my $plugin = shift;
	my ($obj) = @_;
	foreach my $k ('address', 'latitude_g', 'longitude_g', 'zoom_g') {
		if ($obj->$k) {
			return 0;
		}
	}
	return 1;
}

1;
