#!perl -T
use strict;
use warnings;
use Test::More;
use Parse::Zezenen::RecDescent;
use Parse::Zezenen::Filter::Indent;
use Parse::Zezenen::Filter::Serialise;
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;
$Data::Dumper::Indent = 0;
my $parser = Parse::Zezenen::RecDescent->new;
my $indenter = Parse::Zezenen::Filter::Indent->new();
my $serialiser = Parse::Zezenen::Filter::Serialise->new();

foreach my $test ( 
	{
		desc=>"simple element",
		zz=>"b{}"
	},
#	{
#		desc=>"simple element",
#		zz=>"div{ul{li{b{One} list item}li{LI2}li{list item number i{three} } } }"
#	},
)
{
	my $tree = $parser->parse('block',$test->{'zz'});
	my $indented = $indenter->filter($tree, $test->{'args'});
	is_deeply( $serialiser->filter($indented), $test->{'zz'}, $test->{'desc'} . Dumper($tree));
}

done_testing;
