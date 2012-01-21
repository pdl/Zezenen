#!perl -T
use strict;
use warnings;
use Test::More;
use Parse::Zezenen::RecDescent;
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;
my $parser = Parse::Zezenen::RecDescent->new;

# NOTE: All tests are subject to change until the whitespace model is finalised

is_deeply( Parse::Zezenen::RecDescent::_flatten( [ [1,2] ,3] ), [1,2,3], 'Flatten works for 2d lists');
is( $parser->parse('qname', 'test_qname'), 'test_qname', 'qname parses');
is( $parser->parse('qname', '1bad'), undef, 'Not a qname: 1bad');
is( $parser->parse('qname', ''), undef, 'Not a qname: EMPTY STRING');
is( $parser->parse('horizontal_space', ' '), ' ', 'horizontal_space');
is( $parser->parse('horizontal_space', "\t"), "\t", 'horizontal_space');
is( $parser->parse('horizontal_space', "\n\t"), undef, 'Not a horizontal_space: \\n\\t');
is( $parser->parse('line_plus_any_indent', "\n\t"), "\n\t", 'line_plus_any_indent');
is( $parser->parse('textcurlies', "{"), undef, 'textcurlies fails { when no context');
ok( defined $parser->parse('blockcontent', "{simple}"), "blockcontent doesn't fail on {simple}");
is_deeply( $parser->parse('blockcontent', "{simple}"), ['simple'], "blockcontent parses {simple} as ['simple']");
ok( defined $parser->parse('blockcontent', "{{ { }}"), "blockcontent doesn't fail on {{ { }}");
is_deeply( $parser->parse('blockcontent', "{{ { }}"), [' ', '{', ' '], "blockcontent parses {{ { }} as [' ','{',' ']");
is_deeply( $parser->parse('selector_class', ".title-row"), {class=>'title-row'}, 'selector_class works');
is_deeply( $parser->parse('selector_id', "#title-row"), {id=>'title-row'}, 'selector_id works');
is_deeply( $parser->parse('selector_attr', "[href]"), {href=>''}, 'selector_attr works for [href]');
is_deeply( $parser->parse('selector_attr', "[href=1]"), {href=>'1'}, 'selector_attr works for [href=1]');
is_deeply( $parser->parse('selector_attr', "[href='http://example.com/?q=%20']"), {href=>'http://example.com/?q=%20'}, "selector_attr works for [href='http://example.com/?q=%20']");
is_deeply( $parser->parse('selector', "a[href='http://example.com/?q=%20']"), {'#name'=>'a',href=>'http://example.com/?q=%20'}, "selector works for a[href='http://example.com/?q=%20']");
is_deeply( $parser->parse('selector', "div.section-title#content.red"), {'#name'=>'div',class=>'red section-title', id=>'content'}, "selector works for div.section-title#content.red");
is_deeply( $parser->parse('block', "div{ test }"), {'#name'=>'div','~'=>[' ','test',' ']}, 'block parses div{ test }');
is_deeply( $parser->parse('block', "div{test}"), {'#name'=>'div','~'=>['test']}, 'block parses div{test}');

is_deeply( $parser->parse('block', "div{ test{}  }"), {'#name'=>'div','~'=>[' ',{'#name'=>'test', '~'=>[]}, ' ']}, 'block parses div{ test{}  }');
is_deeply( 
	$parser->parse('block',   "p{ a[href]{{  } img{{}} }} }"),
	$parser->parse('block', "p{{ a[href]{{  } img{{}} }} }}"),
	'Extra curlies have no effect');
is_deeply( $parser->parse('block', "b{{ } }}"), {'#name'=>'b','~'=>[' ', '}',]}, "block parses content of b{{ } }} as [' ','{']");
is_deeply( $parser->parse('block', "div{{ b{{test}} } }}"), {'#name'=>'div','~'=>[' ',{'#name'=>'b', '~'=>['test']}, '}']}, "block parses content of div{{ b{{test}} } }} correctly");

is( $parser->parse('directive_marker', '!'), '!', 'directive_marker works');
is_deeply( $parser->parse('element_or_directive_name', "!U"), {'#name'=>'U', '#directive'=>1}, 'element_or_directive_name works');
is_deeply( $parser->parse('block', "!U{a0}"), {'#name'=>'U', '#directive'=>1, '~'=>['a0']}, 'can parse complete directives');
is_deeply( $parser->parse('block', "!PRE{ \n }"), {'#name'=>'PRE', '#directive'=>1, '~'=>[' ', "\n "]}, 'parse does not merge or normalise space nodes');

done_testing;


