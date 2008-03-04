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
	if ($blog_id && ($type eq 'entry')) {
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

sub _hdlr_googlemap_api_key {
    my ($plugin, $ctx, $args) = @_;

	my $hash = $plugin->get_config_hash();
	my $apikey = $hash->{googlemap_api_key};

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
		$apikey = $hash->{googlemap_api_key} || $apikey;
	}

	return $apikey;
}

sub __detect_location {
    my ($plugin, $ctx, $args) = @_;

	require Locator::Location;

	my $for = $args->{of};
	if ((! $for) || ($for eq 'entry')) {
		my $entry = $ctx->stash('entry');
		if ($entry) {
			my $loc = Locator::Location->load({'entry_id' => $entry->id});
			if (! $loc) {
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
		if (! $blog_id) {
			my $b = $ctx->stash('blog');
			if ($b) {
				$blog_id = $b->id;
			}
		}
		if ($blog_id) {
			my $loc = Locator::Location->load({'blog_id' => $blog_id});
			if (! $loc) {
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
		my $loc = Locator::Location->load({'author_id' => $author->id});
		if (! $loc) {
			return 0;
		}
		return $loc;
	}
	else {
		return 0;
	}
}

sub _hdlr_locator_google_map_mobile {
    my ($plugin, $ctx, $args) = @_;
	my $loc = &__detect_location(@_);
	if (! $loc) {
		return '';
	}

	my $lng = $loc->longitude_g;
	my $lat = $loc->latitude_g;

	if ((! $lng) || (! $lat)) {
		return '';
	}

	my ($pre, $post) = split(/\./, $lng . '000000');
	$lng = $pre . substr($post, 0, 6);
	($pre, $post) = split(/\./, $lat . '000000');
	$lat = $pre . substr($post, 0, 6);

	my $zm = int((19 - $loc->zoom_g + 1) * 17 / 20 + 0.5);
	if (defined($args->{zoom})) {
		$zm = $args->{zoom};
	}

	my $width = $args->{width} || '200';
	my $height = $args->{height} || '200';

	my $img = '<img src="' .
	'http://maps.google.com/mapprint?' .
	'&tstyp=4' . 
	'&c=' . $lng . ',' . $lat .
	"&r=$width,$height" .
	#'&z=3' .
	'&z=' . $zm .
	'&l=' . $lng . ',' . $lat . ',' . 15 .
	'"';

	if ($args->{id}) {
		$img .= ' id="' . $args->{id} . '"';
	}
	if ($args->{class}) {
		$img .= ' class="' . $args->{class} . '"';
	}
	if ($args->{style}) {
		$img .= ' style="' . $args->{style} . '"';
	}

	$img . '/>';
}

sub _hdlr_locator_google_map {
    my ($plugin, $ctx, $args, $cond) = @_;
    my $builder = $ctx->stash('builder');
    my $tokens = $ctx->stash('tokens');

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

	my $map_control = 'GLargeMapControl';
	if (defined($args->{'map_control'})) {
		$map_control = $args->{'map_control'};
	}
	&$ctx_set_var('LocatorMapControl', $map_control);

	&$ctx_set_var('LocatorMapID', $args->{id} || 'locator_map');
	&$ctx_set_var('LocatorMapClass', $args->{lass} || '');
	&$ctx_set_var('LocatorMapStyle', $args->{style} || '');

	my $width = $args->{width} || '400px';
	if ($width !~ m/px$/) {
		$width .= 'px';
	}
	my $height = $args->{height} || '400px';
	if ($height !~ m/px$/) {
		$height .= 'px';
	}
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

	$builder->build($ctx, $tmpl_token) or $ctx->error($builder->errstr);
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

1;
