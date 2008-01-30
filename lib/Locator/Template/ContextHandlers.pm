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

sub _hdlr_location_enable_for {
    my ($plugin, $ctx, $args) = @_;
    my $blog_id = $ctx->stash('blog_id');
	if (! $blog_id) {
		my $b = $ctx->stash('blog');
		if ($b) {
			$blog_id = $b->id;
		}
	}

	my $type = lc($ctx->this_tag);
	$type =~ s/mtlocationenablefor//;

	my $hash;
	if ($blog_id && ($type eq 'entry')) {
		$hash = $plugin->get_config_hash('blog:' . $blog_id);
	}
	else {
		$hash = $plugin->get_config_hash();
	}

	return $hash->{'enable_for_' . $type}
}

sub _hdlr_location_field {
    my ($plugin, $ctx, $args) = @_;
    my $blog_id = $ctx->stash('blog_id');
	if (! $blog_id) {
		my $b = $ctx->stash('blog');
		if ($b) {
			$blog_id = $b->id;
		}
	}

	my $type = lc($ctx->this_tag);
	$type =~ s/mtlocationfield//;

	my $hash;
	if ($blog_id) {
		$hash = $plugin->get_config_hash('blog:' . $blog_id);
	}
	else {
		$hash = $plugin->get_config_hash();
	}

	return $hash->{'field_' . $type}
}

sub _hdlr_googlemap_api_key {
    my ($plugin, $ctx, $args) = @_;
	my $hash = $plugin->get_config_hash();
	return $hash->{googlemap_api_key};
}

1;
