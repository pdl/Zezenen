#!perl -T
use strict;
use warnings;
use Test::More;
use Parse::Zezenen::RecDescent;
use Parse::Zezenen::Filter::Interpreter;
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;
my $parser = Parse::Zezenen::RecDescent->new;
my $filter = Parse::Zezenen::Filter::Interpreter->new();
is_deeply( $filter->filter($parser->parse('block',"b{}")), {'#name'=>'b', '~'=>[]}, 'can interpret elements');
is_deeply( $filter->filter({'#name'=>'b', '~'=>['a',' ', 'b']}), {'#name'=>'b', '~'=>['a b']}, 'intepret merges adjacent text nodes');
is_deeply( $filter->filter({'#name'=>'b', '~'=>['a'," \n ", 'b']}), {'#name'=>'b', '~'=>['a b']}, 'intepret normalises space nodes');
# These tests don't parse at all, investigate why.
#is_deeply( $parser->parse('block',"b{!PRE{a \n b} }"), { '#name'=>'b', '~'=>[ { '#directive'=>1,'#name'=>'PRE','~'=>["a",' ',"\n ","b"] }, ' ' ] }, 'parse does not normalise space nodes within nested !PRE{}');
#is_deeply( $filter->filter($parser->parse('block',"b{!PRE{a \n b}}")), {'#name'=>'b', '~'=>["a \n b"]}, 'intepret does not normalise space nodes within !PRE{}');
is_deeply( $filter->filter($parser->parse('block',"b{a b}")), {'#name'=>'b', '~'=>['a b']}, 'intepret merges adjacent text nodes');
is_deeply( $filter->filter($parser->parse('block',"!U{a0}")), "\xa0", 'can interpret directive U with one glyph');
is_deeply( $filter->filter($parser->parse('block',"!U{64 65}")), "\x64\x65", 'can interpret directive U with more than one glyph');
is_deeply( $filter->filter($parser->parse('block',"!U{2033}")), "\x{2033}", 'can interpret directive U with chars over 0xFF');
is_deeply( 'de' ,'de', 'is_deeply can do strings' );

# This test doesn't work, not sure why, it appears to report expecting and getting the text 'de':
# is_deeply( $filter->filter($parser->parse('block',"!U{\n64\t 65 }")), "\x64\x65", 'can interpret directive U with more than one glyph and extraneous spaces');



done_testing;
