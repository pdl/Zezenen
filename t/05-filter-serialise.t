#!perl -T
use strict;
use warnings;
use Test::More;
use Parse::Zezenen::RecDescent;
use Parse::Zezenen::Filter::Serialise;
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;
my $parser = Parse::Zezenen::RecDescent->new;
my $filter = Parse::Zezenen::Filter::Serialise->new();

foreach my $test ( 
	{
		desc=>"simple element",
		zz=>"b{}"
	},
	{
		desc=>"simple element with content",
		zz=>"b{test}"
	},
	{
		desc=>"simple element with mixed content",
		zz=>"p{b{mixed} content}"
	},
	{
		desc=>"simple element with mixed content ending in element",
		zz=>"p{b{mixed} i{content} }"
	},
	{
		desc=>"double curlies",
		zz=>"code{{} }}"
	},
	{
		desc=>"simple attribute",
		zz=>'b[color="red"]{test}'
	},
	{
		desc=>"simple attribute with escaped quotes",
		zz=>"b[style=\"color: \\\"red\\\"\"]{test}"
	},

)
{
	is_deeply( $filter->filter($parser->parse('block',$test->{'zz'})), $test->{'zz'}, $test->{'desc'});
}

done_testing;
