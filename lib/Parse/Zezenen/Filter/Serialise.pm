package Parse::Zezenen::Filter::Serialise;
use 5.006;
use strict;
use warnings;
use base "Parse::Zezenen::Filter::Base";
use Data::Dumper;
=head1 NAME

Parse::Zezenen::Filter::Serialise

=cut

sub filter_string
{
	my ($self, $target, $args) = @_;
#	my $iCurlies = $args->{'curlies'};
#	while $target =~ s/(\{+|\}+)/$1/g # !U{&sprintf("%x", &ord(substr($1,1,1))) x length $1}/g;
#	{
#		$args->{'curlies'} = length $1;
#	}
	return $target;
}
sub filter_array
{
	my ($self, $target, $args) = @_;
	$target = $self->array_merge_text_nodes($target, $args);
	foreach my $i ( 1 .. $#{$target} )
	{
		if (ref($target->[$i]) eq ref (''))
		{
			if (ref ($target->[$i-1]) eq ref ({}))
			{
				$target->[$i] =~ s/^([\x20\t]*\})/ $1/; 
			}
		}
	}
	my $s = join ('', map{$self->filter($_, $args)} @{$target});
	if ($s =~ m/\}[\x20\t]*$/)
	{
		$s .= ' ';
	}
	return $s;
}
sub filter_directive
{
	my ($self, $target, $args) = @_;
	return $self->filter_element($target, $args);
}
sub filter_element
{
	my ($self, $target, $args) = @_;
	my $iCurlies = $self->get_curlies($target);
	$iCurlies||=1;
	$iCurlies = $args->{'curlies'} if defined ($args->{'curlies'}) and $iCurlies < $args->{'curlies'};
	my $s='';
	$s .= '!' if $target->{'#directive'};
	$s .= $target->{'#name'};
	foreach my $key (keys %{$target})
	{
		next if $key =~ /^[#~]/;
		my $val = $target->{$key};
		$val =~ s/\"/\"/g;
		$s .= '['.$key.'="'.$val.'"]';
	}
	$s .= ('{' x $iCurlies) . ($self->filter($target->{'~'}, {%$args, curlies=>$iCurlies})) . ('}' x $iCurlies);
	return $s;
}
sub get_curlies
{
	my ($self, $target, $args) = @_;
	my $iCurlies = 0;
	foreach my $node (@{$target->{'~'}})
	{
		my $i = 0;
		if (ref ($node) eq ref({}))
		{
			$i = $self->get_curlies($_, $args);
		}
		elsif (ref ($node) eq ref(''))
		{
			foreach (split (/(\{+|\}+)/, $node))
			{
				if ( m/(\{+|\}+)$/)
				{
					$i = (length ($1) +1) unless (length ($1) + 1) < $i;
				}
			}
		}		
		$iCurlies = $i if $iCurlies<$i;
	}	
	return $iCurlies;
}
1;
