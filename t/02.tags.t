use strict;
use warnings;

use Test::Base;
plan tests => 2 * blocks;

use MT::App::Test;
use File::Basename;

# preprare app object
use MT::App::Test;
my $app = MT::App::Test->test_instance_of(
	#force_initialize_database => 1,
	data_dirs => dirname(__FILE__),
) or die MT::App::Test->errstr;

$app->test_template_load_context('ctx_1');

sub content {
	my ($str) = @_;
	require File::Spec;
	do {
		open(my $fh, '<', File::Spec->catfile(dirname(__FILE__), $str));
		local $/;
		<$fh>;
	};
}

sub stuffs_blank {
	my ($str) = @_;
	$str =~ s/\s+/ /g;
	$str =~ s/^\s*|\s*$//g;
	$str;
}

filters {
	input => [qw( chomp )],
	expected => [qw( chomp )],
};

run {
	my $block = shift;
	my $input = $block->input;
	is(
		&stuffs_blank($app->test_template_build(\$input)),
		$block->expected, $block->name
	);
};

my $testable = $app->test_is_php_testable;
run {
	my $block = shift;
	SKIP: {
		if (! $testable) {
			skip("Can't test test_php_template_build()", 1);
		}
		my $input = $block->input;
		is(
			&stuffs_blank($app->test_php_template_build(\$input)),
			$block->expected, $block->name
		);
	}
};

if (my $log = $app->test_log) {
#	diag($log);
}

__END__

=== LocatorFieldAddress
--- input
<mt:LocatorFieldAddress>
--- expected
2

=== LocatorFieldMap
--- input
<mt:LocatorFieldMap>
--- expected
2

=== LocatorFieldZoom
--- input
<mt:LocatorFieldZoom>
--- expected
1

=== LocatorEnableForAuthor
--- input
<mt:LocatorEnableForAuthor>
--- expected
1

=== LocatorEnableForBlog
--- input
<mt:LocatorEnableForBlog>
--- expected
1

=== LocatorEnableForEntry
--- input
<mt:LocatorEnableForEntry>
--- expected
1

=== GoogleMapAPIKey
--- input
<mt:GoogleMapAPIKey>
--- expected
abcdefg

=== LocatorLatitude
--- input
<mt:LocatorLatitude>
--- expected
1.1

=== LocatorLongitude
--- input
<mt:LocatorLongitude>
--- expected
2.2

=== LocatorZoom
--- input
<mt:LocatorZoom>
--- expected
1

=== LocatorAddress
--- input
<mt:LocatorAddress>
--- expected
Test Address

=== LocatorHasMap - has map
--- input
<mt:LocatorHasMap>has map</mt:LocatorHasMap>
--- expected
has map

=== LocatorGoogleMapMobile
--- input
<mt:LocatorGoogleMapMobile>
--- expected
<img src="http://maps.google.com/staticmap?center=1.1,2.2&zoom=1&size=200x200&maptype=mobile&key=abcdefg"/>

=== LocatorGoogleMap
--- input
<mt:LocatorGoogleMap>EntryID: <mt:EntryID></mt:LocatorGoogleMap>
--- expected content stuffs_blank
tag_LocatorGoogleMap.html
