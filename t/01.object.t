use strict;
use warnings;
use Test::More tests => 20;

use File::Basename;
use File::Spec;


# preprare app object
use MT::App::Test;
my $app = MT::App::Test->test_instance_of(
	#force_initialize_database => 1,
	data_dirs => dirname(__FILE__),
) or die MT::App::Test->errstr;


# prepare classes
my $blog_class = $app->test_model('blog');
my $entry_class = $app->test_model('entry');
my $author_class = $app->test_model('author');
my $log_class = $app->test_model('log');


# for entry's
{
	my %entry_ids = ();
	my $location_value = $app->test_request_load_param('req_entry');

	my $entry = $entry_class->test_load_volatiles('entry_1');
	$entry->save;
	$entry_ids{'insert'} = $entry->id;

	($entry) = $entry_class->load;
	$entry->save;
	$entry_ids{'update'} = $entry->id;

	require Locator::Location;
	foreach my $type (keys(%entry_ids)) {
		my $id = $entry_ids{$type};
		my $loc = Locator::Location->load({
			'entry_id' => $id,
		});
		ok($loc, 'location object [type="' . $type . '"]');
		foreach my $key (keys(%$location_value)) {
			if ($key !~ m/^location_/) {
				next;
			}
			(my $lk = $key) =~ s/^location_//;
			is(
				$loc->$lk, $location_value->{$key},
				'location object [type="' . $type . '" key="' . $key . '"]'
			);
		}
	}
}


# for blog's
{
	my $location_value = $app->test_request_load_param('req_blog');

	my ($blog) = $blog_class->load;
	$blog->save;

	my $loc = Locator::Location->load({
		'blog_id' => $blog->id,
	});
	ok($loc, 'location object [type="blog"]');
	foreach my $key (keys(%$location_value)) {
		if ($key !~ m/^location_/) {
			next;
		}
		(my $lk = $key) =~ s/^location_//;
		is(
			$loc->$lk, $location_value->{$key},
			'location object [type="blog" key="' . $key . '"]'
		);
	}
}


# for authors's
{
	my $location_value = $app->test_request_load_param('req_author');

	my ($author) = $author_class->load;
	$author->save;

	my $loc = Locator::Location->load({
		'author_id' => $author->id,
	});
	ok($loc, 'location object [type="author"]');
	foreach my $key (keys(%$location_value)) {
		if ($key !~ m/^location_/) {
			next;
		}
		(my $lk = $key) =~ s/^location_//;
		is(
			$loc->$lk, $location_value->{$key},
			'location object [type="blog" key="' . $key . '"]'
		);
	}
}


if (my $log = $app->test_log) {
#	diag($log);
}
