use strict;
use warnings;
use Test::More tests => 7;

BEGIN {
	my @files = qw(
Locator/Template/ContextHandlers.pm
Locator/Location.pm
Locator/App.pm
Locator/L10N.pm
Locator/L10N/en_us.pm
Locator/L10N/ja.pm
	);
	foreach (@files) {
		s#/#::#g;
		s/\.pm$//;
		use_ok $_;
	}
}   

# preprare app object
use MT::App::Test;
my $app = MT::App::Test->test_instance_of
	or die MT::App::Test->errstr;

ok($app->component('locator'), 'component')
