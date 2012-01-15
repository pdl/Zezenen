#!perl -T

use Test::More tests => 2;

BEGIN {
    use_ok( 'Parse::Zezenen::RecDescent' ) || print "Bail out!\n";
    use_ok( 'Parse::Zezenen::Filter::Base' ) || print "Bail out!\n";
}

diag( "Testing Parse::Zezenen::RecDescent $Parse::Zezenen::RecDescent::VERSION, Perl $], $^X" );
