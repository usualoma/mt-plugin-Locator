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

package Locator::Template::ContextHandlers;

use strict;

sub _hdlr_locator_enable_for {
    my ($plugin, $ctx, $args) = @_;
    my $blog_id = $ctx->stash('blog_id');
	if (! $blog_id) {
		my $b = $ctx->stash('blog');
		if ($b) {
			$blog_id = $b->id;
		}
	}

	my $type = lc($ctx->this_tag);
	$type =~ s/mtlocatorenablefor//;

	my $hash;
	if ($blog_id && ($type eq 'entry' || $type eq 'page')) {
		$hash = $plugin->get_config_hash('blog:' . $blog_id);
	}
	else {
		$hash = $plugin->get_config_hash();
	}

	return $hash->{'enable_for_' . $type} || 0;
}

sub _hdlr_locator_field {
    my ($plugin, $ctx, $args) = @_;
    my $blog_id = $ctx->stash('blog_id');
	if (! $blog_id) {
		my $b = $ctx->stash('blog');
		if ($b) {
			$blog_id = $b->id;
		}
	}

	my $type = lc($ctx->this_tag);
	$type =~ s/mtlocatorfield//;

	my $hash = $plugin->get_config_hash();

	return $hash->{'field_' . $type} || 0;
}

sub _hdlr_config_key {
    my ($key, $plugin, $ctx, $args) = @_;

	my $hash = $plugin->get_config_hash();
	$key = $hash->{$key};

	if (
		$ctx->{current_archive_type} ||
		$ctx->{archive_type} ||
		$ctx->{inside_mt_categories}
	) {
		my $blog_id = $ctx->stash('blog_id');
		if (! $blog_id) {
			my $b = $ctx->stash('blog');
			if ($b) {
				$blog_id = $b->id;
			}
		}
		my $hash = $plugin->get_config_hash('blog:' . $blog_id);
		$key = $hash->{$key} || $key;
	}

	return $key;
}

sub _hdlr_googlemap_api_key {
    my ($plugin, $ctx, $args) = @_;
    _hdlr_config_key('googlemap_api_key', @_);
}

sub _hdlr_googlemap_client_id {
    my ($plugin, $ctx, $args) = @_;
    _hdlr_config_key('googlemap_client_id', @_);
}

sub _hdlr_googlemap_crypto_key {
    my ($plugin, $ctx, $args) = @_;
    _hdlr_config_key('googlemap_crypto_key', @_);
}

sub __detect_location {
    my ($plugin, $ctx, $args) = @_;

	require Locator::Location;

	my $for = $args->{of} || $ctx->stash('locator_google_map_of') || '';
	if ((! $for) || ($for eq 'entry')) {
		my $entry = $ctx->stash('entry');
		if ($entry) {
			my $loc = $entry;
			if (MT->version_number < 5) {
				$loc = Locator::Location->load({'entry_id' => $entry->id});
			}

			if (! $loc || $plugin->is_empty($loc)) {
				return 0;
			}
			return $loc;
		}

		if ($for eq 'entry') {
			return 0;
		}
	}

	if ((! $for) || ($for eq 'blog')) {
		my $blog_id = $ctx->stash('blog_id');
		my $blog = $ctx->stash('blog');
		if (! $blog_id) {
			if ($blog) {
				$blog_id = $blog->id;
			}
		}
		if ($blog_id) {
			my $blog = $blog || MT::Blog->load($blog_id);
			my $loc = $blog;
			if (MT->version_number < 5) {
				$loc = Locator::Location->load({'blog_id' => $blog_id});
			}

			if (! $loc || $plugin->is_empty($loc)) {
				return 0;
			}
			return $loc;
		}

		if ($for eq 'blog') {
			return 0;
		}
	}

	my $author = $ctx->stash('author');
	if ($author) {
		my $loc = $author;
		if (MT->version_number < 5) {
			$loc = Locator::Location->load({'author_id' => $author->id});
		}

		if (! $loc || $plugin->is_empty($loc)) {
			return 0;
		}
		return $loc;
	}
	else {
		return 0;
	}
}

# http://adiary.blog.abk.nu/0274
sub hmac_sha1 {
    # my $self = shift;
    my ( $key, $msg ) = @_;
    my $sha1;

    if ($Digest::SHA::PurePerl::VERSION) {
        $sha1 = Digest::SHA::PurePerl->new(1);
    }
    else {
        eval {
            require Digest::SHA1;
            $sha1 = Digest::SHA1->new;
        };
        if ($@) {
            require Digest::SHA::PurePerl;
            $sha1 = Digest::SHA::PurePerl->new(1);
        }
    }

    my $bs = 64;
    if ( length($key) > $bs ) {
        $key = $sha1->add($key)->digest;
        $sha1->reset;
    }
    my $k_opad = $key ^ ( "\x5c" x $bs );
    my $k_ipad = $key ^ ( "\x36" x $bs );
    $sha1->add($k_ipad);
    $sha1->add($msg);
    my $hk_ipad = $sha1->digest;
    $sha1->reset;
    $sha1->add( $k_opad, $hk_ipad );

    my $b64d = $sha1->b64digest;
    $b64d = substr( $b64d . '====', 0, ( ( length($b64d) + 3 ) >> 2 ) << 2 );
    return $b64d;
}

sub _hdlr_locator_google_map_mobile {
    my ($plugin, $ctx, $args) = @_;
	my $loc = &__detect_location(@_);
	if (! $loc) {
		return '';
	}

	my $hash = $plugin->get_config_hash();
	my $client_id = $hash->{googlemap_client_id};
	if (
		$ctx->{current_archive_type} ||
		$ctx->{archive_type} ||
		$ctx->{inside_mt_categories}
	) {
		my $blog_id = $ctx->stash('blog_id');
		if (! $blog_id) {
			my $b = $ctx->stash('blog');
			if ($b) {
				$blog_id = $b->id;
			}
		}
		my $hash = $plugin->get_config_hash('blog:' . $blog_id);
		$client_id = $hash->{googlemap_client_id} || $client_id;
	}

	my $crypto_key = $hash->{googlemap_crypto_key};
	if (
		$ctx->{current_archive_type} ||
		$ctx->{archive_type} ||
		$ctx->{inside_mt_categories}
	) {
		my $blog_id = $ctx->stash('blog_id');
		if (! $blog_id) {
			my $b = $ctx->stash('blog');
			if ($b) {
				$blog_id = $b->id;
			}
		}
		my $hash = $plugin->get_config_hash('blog:' . $blog_id);
		$crypto_key = $hash->{googlemap_crypto_key} || $crypto_key;
	}

	my $lng = $loc->longitude_g;
	my $lat = $loc->latitude_g;

	if ((! $lng) || (! $lat)) {
		return '';
	}

    require MT;
    my $zoom = $args->{zoom} || $ctx->stash('locator_zoom') || $loc->zoom_g || $plugin->translate('Location default zoomlevel');

	my $width = $args->{width} || '200';
	my $height = $args->{height} || '200';
	my $maptype = $args->{maptype} || 'roadmap';
	my $protocol = $args->{protocol} || 'http';

    my $portion_to_sign =
        '/maps/api/staticmap?' .
        'sensor=false' .
        ($client_id ? ('&client=' . $client_id) : '') .
        '&center=' . $lat . ',' . $lng .
	    '&zoom=' . $zoom .
        '&size=' . $width . 'x' . $height .
        '&maptype=' . $maptype .
	    '&markers=' . $lat . ',' . $lng;

	if ($args->{id}) {
		$portion_to_sign .= ' id="' . $args->{id} . '"';
	}
	if ($args->{class}) {
		$portion_to_sign .= ' class="' . $args->{class} . '"';
	}
	if ($args->{style}) {
		$portion_to_sign .= ' style="' . $args->{style} . '"';
	}

    my $sign = '';
    if ($crypto_key) {
        require MIME::Base64;
        $sign = '&signature='
            . hmac_sha1( MIME::Base64::decode_base64($crypto_key),
            $portion_to_sign );
    }

    qq{<img src="$protocol://maps.google.com$portion_to_sign$sign" />};
}

sub _hdlr_locator_google_map {
    my ($plugin, $ctx, $args, $cond) = @_;
    my $builder = $ctx->stash('builder');
    my $tokens = $ctx->stash('tokens');

	local $ctx->{__stash}{locator_google_map_of} = $args->{of} || '';

	my $loc = &__detect_location(@_);
	if (! $loc) {
		return '';
	}

	my $lng = $loc->longitude_g;
	my $lat = $loc->latitude_g;

	if ((! $lng) || (! $lat)) {
		return '';
	}


	my $ctx_set_var;
	if (MT->version_number >= 4) {
		$ctx_set_var = sub {
			$ctx->var(@_);
		}
	}
	else {
		$ctx_set_var = sub {
			$ctx->{__stash}{vars}{$_[0]} = $_[1];
		}
	}

    &$ctx_set_var('LocatorMapTypeControl', defined($args->{map_type_control}) ? $args->{map_type_control} : 'true');
    &$ctx_set_var('LocatorPanControl', defined($args->{pan_control}) ? $args->{pan_control} : 'true');
    &$ctx_set_var('LocatorZoomControl', defined($args->{zoom_control}) ? $args->{zoom_control} : 'true');
    &$ctx_set_var('LocatorScaleControl', defined($args->{scale_control}) ? $args->{scale_control} : 'true');
    &$ctx_set_var('LocatorStreetViewControl', defined($args->{street_view_control}) ? $args->{street_view_control} : 'true');
    &$ctx_set_var('LocatorOpenInfoWindow', defined($args->{open_info_window}) ? $args->{open_info_window} : 'true');

	&$ctx_set_var('LocatorMapID', $args->{id} || 'locator_map');
	&$ctx_set_var('LocatorMapClass', $args->{class} || '');
	&$ctx_set_var('LocatorMapStyle', $args->{style} || '');

	my $width = defined($args->{width}) ?  $args->{width} : '400px';
	$width =~ s/(\d)$/$1px/;

	my $height = defined($args->{height}) ? $args->{height} : '400px';
	$height =~ s/(\d)$/$1px/;

	&$ctx_set_var('LocatorMapWidth', $width);
	&$ctx_set_var('LocatorMapHeight', $height);

	if (defined($args->{zoom})) {
		$ctx->stash('locator_zoom', $args->{zoom});
	}

	defined(my $inner = $builder->build($ctx, $tokens, $cond))
		or return $ctx->error($builder->errstr);
	#using encode_js="1"
	#$inner =~ s/\n//g;
	$inner =~ s/^[\s\n]*$//;
	&$ctx_set_var('LocatorInfoWindow', $inner);

	my $edit_map_tmpl = File::Spec->catdir($plugin->{full_path},'tmpl','tag_google_map.tmpl');
	#my $tmpl = do { open(my $fh, $edit_map_tmpl); local $/; <$fh> };
	my $tmpl = $plugin->load_tmpl_translated($edit_map_tmpl);
	my $tmpl_token = $builder->compile($ctx, $tmpl);

	$ctx->stash('locator_zoom', undef);

    my $result = do {
        if ( defined( $args->{load_script} ) ) {
            local $ctx->{__stash}{vars}{locator_script_loaded}
                = !$args->{load_script};
        }
	    $builder->build($ctx, $tmpl_token) or $ctx->error($builder->errstr);
    };

    $ctx->{__stash}{vars}{locator_script_loaded} = 1;

    $result;
}

sub _hdlr_locator_has_map {
    my ($plugin, $ctx, $args, $cond) = @_;
    my $builder = $ctx->stash('builder');
    my $tokens = $ctx->stash('tokens');

	my $loc = &__detect_location(@_);
	if (! $loc) {
		return 0;
	}

	my $lng = $loc->longitude_g;
	my $lat = $loc->latitude_g;

	if ((! $lng) || (! $lat)) {
		return 0;
	}

	return 1;
}

sub _hdlr_locator_is_premier {
    my ($plugin, $ctx, $args, $cond) = @_;
    MT->config->LocatorIsPremier;
}

sub _hdlr_locator_latitude_g {
    my ($plugin, $ctx, $args) = @_;
	my $loc = &__detect_location(@_);
	if (! $loc) {
		return '';
	}

	return $ctx->stash('locator_latitude') || $loc->latitude_g || '';
}

sub _hdlr_locator_longitude_g {
    my ($plugin, $ctx, $args) = @_;
	my $loc = &__detect_location(@_);
	if (! $loc) {
		return '';
	}

	return $ctx->stash('locator_longitude') || $loc->longitude_g || '';
}

sub _hdlr_locator_zoom_g {
    my ($plugin, $ctx, $args) = @_;
	my $loc = &__detect_location(@_);
	if (! $loc) {
		return '';
	}

	if ((! $ctx->stash('locator_longitude')) && (! $loc->longitude_g)) {
		return '';
	}
	else {
		return $ctx->stash('locator_zoom') || $loc->zoom_g || '';
	}
}

sub _hdlr_locator_address {
    my ($plugin, $ctx, $args) = @_;
	my $loc = &__detect_location(@_);
	if (! $loc) {
		return '';
	}

	return $ctx->stash('locator_address') || $loc->address || '';
}

sub _hdlr_locator_nearest_entries {
    my ( $plugin, $ctx, $args, $cond ) = @_;

    my $loc = &__detect_location(@_);
    if ( !$loc ) {
        return '';
    }

    my $lat = $ctx->stash('locator_latitude') || $loc->latitude_g
        or return '';
    my $lng = $ctx->stash('locator_longitude') || $loc->longitude_g
        or return '';
    my $distance = $args->{distance} || 10;
    my $limit    = $args->{nearestn} || 10;
    my $blog     = $ctx->stash('blog');

    return unless $lat =~ /^[\d\.]+$/ && $lng =~ /^[\d\.]+$/;

    my $condition
        = "SQRT(POWER(('$lat' - mt_entry.entry_latitude_g) / 0.0111, 2) + POWER(('$lng' - mt_entry.entry_longitude_g) / 0.0091, 2))";
    my @entries = MT->model('entry')->load(
        [   {   blog_id        => $blog->id,
                "!$condition!" => { op => '<=', value => $distance },
                (   $loc->isa('MT::Entry')
                    ? ( id => { not => $loc->id } )
                    : ()
                )
            }
        ],
        {   limit => $limit,
            sort  => "!$condition!",
        }
    );

    return '' unless @entries;

    local $ctx->{__stash}{entries} = \@entries;
    local $ctx->{archive_type};
    my $handler = $ctx->handler_for('entries');
    $handler->invoke( $ctx, $args, $cond ) or return '';
}

1;
