#!perl -T
use strict;
use warnings;
use Test::More;
use Parse::Zezenen::RecDescent;
use Parse::Zezenen::Filter::LibXML;
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;
my $parser = Parse::Zezenen::RecDescent->new;
my $filter = Parse::Zezenen::Filter::LibXML->new();

# NOTE: All tests are subject to change until the whitespace model is finalised

is($filter->filter($parser->parse('block','div{test}'))->toString,'<div>test</div>', 'Simple block is ok');
is($filter->filter($parser->parse('block','div{ test }'))->toString,'<div> test </div>', 'Spaces preserved ok');
is($filter->filter($parser->parse('block','div{ b{test}  }'))->toString,'<div> <b>test</b> </div>', 'Nesting works ok');
is($filter->filter($parser->parse('block','div{{ b{{test}} } }}'))->toString,'<div> <b>test</b>}</div>', 'Space-curly handling works ok');
is($filter->filter($parser->parse('block','div{{ b{{test}}  } }}'))->toString,'<div> <b>test</b> }</div>', 'Space-curly handling works ok');
is($filter->filter($parser->parse('block','div{ b{test} more text }'))->toString,'<div> <b>test</b> more text </div>', 'Mixed content');
is($filter->filter($parser->parse('block','div[style="float:left;"]{test}'))->toString,'<div style="float:left;">test</div>', 'Attributes work');
# is($filter->filter($parser->parse('block','!PI[target="xml:stylesheet"]{href="test.css"}'))->toString,'<div style="float:left;">test</div>', 'Attributes work');



done_testing;
