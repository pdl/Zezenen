#!perl -T
use strict;
use warnings;
use Test::More;
use Parse::Zezenen::RecDescent;
use Parse::Zezenen::Filter::Serialise;
use Data::Dumper;
$Data::Dumper::Sortkeys = 1;
$Data::Dumper::Indent = 0;
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
		desc=>"double curlies with mixed content",
		zz=>"code{{}b{{}} }}"
	},
	{
		desc=>"double curlies with mixed content and triple curlies",
		zz=>"code{{}b{{{}} }}} }}"
	},
#	{
#		desc=>"double curlies with mixed content and triple curlies and closing text curly after element",
#		zz=>"code{{}b{{{}} }}} } }}"
#	},
	{
		args=>{'break'=>1},
		desc=>"double curlies with mixed content and triple curlies and space+closing text curly after element",
		zz=>"code{{}b{{{}} }}}  } }}"
	},
	{
		desc=>"directive",
		zz=>'!TEST{contents}'
	},
	{
		desc=>"simple attribute",
		zz=>'b[color="red"]{test}'
	},
	{
		desc=>"simple attribute with escaped quotes",
		zz=>"b[style=\"color: \\\"red\\\"\"]{test}"
	},
	{
		desc=>"namespaces!",
		zz=>'xsl:template[match="*"]{xsl:copy-of[select="@*|node()"]{} }'
	},

)
{
	my $tree = $parser->parse('block',$test->{'zz'});
	is_deeply( $filter->filter($tree, $test->{'args'}), $test->{'zz'}, $test->{'desc'} . Dumper($tree));
}

done_testing;
