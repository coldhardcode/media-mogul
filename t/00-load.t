#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Media::Mogul' );
}

diag( "Testing Media::Mogul $Media::Mogul::VERSION, Perl $], $^X" );
