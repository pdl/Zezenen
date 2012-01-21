#!perl -T
use strict;
use warnings;
use Test::More;
use Parse::Zezenen::RecDescent;
use Parse::Zezenen::Filter::Base;
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;
my $parser = Parse::Zezenen::RecDescent->new;
my $filter = Parse::Zezenen::Filter::Base->new();
is_deeply($filter->array_merge_text_nodes([' ', '}']) , [' }'],'array_merge_text_nodes works');
is_deeply($filter->array_merge_text_nodes([' ', ' ']) , ['  '],'array_merge_text_nodes works');
is_deeply($filter->array_merge_text_nodes(['',' ', '}']) , [' }'],'array_merge_text_nodes works');
is_deeply($filter->array_merge_text_nodes([ {},' ', '}']) , [{},' }'],'array_merge_text_nodes works');
is_deeply($filter->array_merge_text_nodes(['{', {},' ', '}']) , ['{', {},' }'],'array_merge_text_nodes works');
is_deeply( $filter->filter($parser->parse('block', "div{test}")), {'#name'=>'div','~'=>['test']}, 'simple block is identical');
# is_deeply( $parser->parse('block', "div{ test }"), {'#name'=>'div','~'=>[' ','test',' ']}, 'simple block is identical');



done_testing;
