package Parse::Zezenen::RecDescent;
use 5.006;
use strict;
use warnings;
use Regexp::Common;
use Parse::RecDescent;
$Parse::RecDescent::skip = '';
$::RD_HINT = 1;
$::RD_WARN = 1;


=head1 NAME

Parse::Zezenen::RecDescent - The great new Parse::Zezenen::RecDescent!

=head1 VERSION

Version 0.01

=cut
our $VERSION = '0.01';
our $sGrammarItems = [
	#	qname: /[A-Za-z][\\w\\-]*/

q`
	qname: /([A-Za-z][\\w\\-]*:)?[A-Za-z][\\w\\-]*/
`,
q`
	horizontal_space: /[\\t\\x20]+/ 
	line_plus_any_indent: /(?:\\r\\n|\\n|\\r)[\\t\\x20]*/
	non_space_text: /[^{}!\\s\\t\\r\\n]+/
	any_space: /[\\r\\t\\n\\x20]/
`,
q`
	textcurlies: (/(?<!\\{)\\{+/ | /(?<!\\})\\}+/)
	{
		$arg{curlies} = 0 unless defined $arg{curlies};
		$return = $item[-1];
		if (length ($return) >= $arg{curlies})
		{
			$return = undef;
		}
	}
`,
q`
	node: (block[%arg] | textcurlies[%arg] | non_space_text[%arg] | line_plus_any_indent[%arg] | horizontal_space[%arg])
`,
q`
	blockcontent: /(?<!\\{)\\{+(?!\\{)/ node[%arg, 'curlies'=>length($item[1])](s?) /(?<!\\})\\}+/ 
	{
		$return = $item[2];
		if (defined $arg{curlies})
		{
			if (length ($item[1]) ne length ($item[-1]) or length ($item[1]) < $arg{curlies})
			{
				$return = undef;
			}
		}
	}
`,
q`
	block: selector any_space(s?) blockcontent[%arg]
	{
		my $content = $item{blockcontent}; # map {@{$_} if ref $_ eq ref []}
		# this bit removes the final space in a block if the preceding non-horizontal-space character is an element or ends in }. 
		if ($#{$content}>0 and $content->[-1] =~ /^[\\t\\x20]+$/ and (ref($content->[-2]) eq ref{} or (ref($content->[-2]) eq ref ('') and $content->[-2]=~m/\}$/ )))
		{
			chop $content->[-1];
			$#{$content}-- if $content->[-1] eq '';
		}
		$return = {%{$item{selector}}, '~'=>$content};
	}	

`,
q`
	selector_class: '.' qname {$return={class=>$item{qname},};}
	positive_integer: /[0-9]*[1-9][0-9]*/
	selector_iterator: '*' positive_integer {$return={'#iterate'=>$item{positive_integer},};}
	selector_id: '#' qname {$return={id=>$item{qname},};}
	single_quoted_string: /`.$RE{delimited}{-delim=>"'"}.q`/ {$return = substr($item[1],1,length ($item[1])-2);}
	double_quoted_string: /`.$RE{delimited}{-delim=>'"'}.q`/ {$return = substr($item[1],1,length ($item[1])-2);}
	selector_attr_value: (single_quoted_string | double_quoted_string | /\w+/)
	selector_attr_specified: '[' qname '=' selector_attr_value ']' {$return={$item{qname}=>$item{selector_attr_value}};}
	selector_attr_unspecified: '[' qname ']' {$return={$item{qname}=>''};}
	selector_attr: (selector_attr_unspecified | selector_attr_specified)

	selector_multi: ( selector_attr | selector_class )
	directive_marker: '!'
	element_or_directive_name: /!?([A-Za-z][\\w\\-]*:)?[A-Za-z][\\w\\-]*/
	{
		$return = {};
		$return->{'#directive'} = 1 if $item[1] =~ s/^!//;
		$return->{'#name'}=$item[1];
		
	}
	selector: element_or_directive_name(1) selector_multi(s?) selector_id(?) selector_multi(s?) selector_iterator(?)
	{
		my $var = {};
		shift @item;
		foreach my $item (map {@{$_}} @item)
		{
			
			foreach my $key (keys %{$item}) 
			{
				if ($key eq 'class' and defined $var->{class} and $var->{class} ne '')
				{
					$var->{class}.=' '.$item->{$key}
				}
				else
				{
					$var->{$key} = $item->{$key};
				}
			}
		}
		if (defined $var->{class} and $var->{class} =~ /\s/)
		{
			$var->{class} = join (' ', (sort {lc $a cmp lc $b} split (/\s/, $var->{class})));
		}
		$return=$var;
	}
`
];
sub new
{
	my $class = shift;
	my $sGrammar = &_make_grammar;
	my $self = 
	{
		'parser' => Parse::RecDescent->new($sGrammar)
	};
	bless $self, $class;
}
sub _flatten
{
	my $aoa = shift;
	my $flat = [];
	foreach (@{$aoa})
	{
		if (ref $_ eq ref [])
		{
			push @$flat, @{$_}; 
		}
		else
		{
			push @$flat, $_; 
		}
	}
	return $flat;
}
sub _stringify_arrayref
{
	my $array = _flatten shift;
	my $s = '';
	foreach (@$array)
	{
		$s .= $_ if ref ($_) eq ref '';
		$s .= ${$_} if ref ($_) eq ref \'';
	}
	return $s;
}
sub _make_grammar
{
	return 	_stringify_arrayref ($sGrammarItems);
}
sub parse
{
	my ( $self , $sType, $sToParse, $args) = @_;
	$args = {} unless defined $args;
	if (defined $sType)
	{
		return $self->{'parser'}->$sType($sToParse, %$args);
	}
	return undef;
}



1; # End of Parse::Zezenen::RecDescent

=head1 AUTHOR

Daniel Perrett, C<< <perrettdl at googlemail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-parse-zezenen-recdescent-0.01 at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Parse-Zezenen-RecDescent-0.01>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Parse::Zezenen::RecDescent


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Parse-Zezenen-RecDescent-0.01>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Parse-Zezenen-RecDescent-0.01>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Parse-Zezenen-RecDescent-0.01>

=item * Search CPAN

L<http://search.cpan.org/dist/Parse-Zezenen-RecDescent-0.01/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Daniel Perrett.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

