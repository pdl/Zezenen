package Parse::Zezenen::Filter::LibXML;
use 5.006;
use strict;
use warnings;
use base "Parse::Zezenen::Filter::Base";
use XML::LibXML;

=head1 NAME

Parse::Zezenen::Filter::LibXML

=cut

sub filter_string
{
	my ($self, $target, $args) = @_;
	return XML::LibXML::Text->new($target);
}
sub filter_array
{
	my ($self, $target, $args) = @_;
	my @interpreted = map {$self->filter($_,$args)} @$target;
}
sub filter_element
{
	my ($self, $target, $args) = @_;
	my $e;
	$e = XML::LibXML::Element->new($target->{'#name'});
	foreach my $key (keys %$target)
	{
		if ($key eq '~')
		{
			foreach my $nChild (@{$target->{$key}})
			{
				$nChild = $self->filter($nChild,$args);
				# TODO: Flatten lists where directives exist.
				$e->appendChild($nChild);
			}
		}
		elsif ($key !~ /^#/)
		{
			$e->setAttribute($key, $target->{$key});
		}
	}
	return $e;
}
sub filter_directive
{
	my ($self, $target, $args) = @_;
	if ($target->{'#name'} eq 'PI' and $target->{'target'})
	{
		my $pi = XML::LibXML::PI->new(); # This method doesn't exist. Why not?!
		$pi->setNodeName($target->{'target'});
		$pi->setData(join('',map {$self->filter($_, $args)} @{$target->{'~'}}));
		return $pi;
	}
	return [map {$self->filter($_, $args)} @{$target->{'~'}}];
}
sub filter #Takes a parse tree and processes it
{
	my ($self, $target, $args) = @_;
	return undef unless defined $target;
	if (ref ($target) eq ref (''))
	{
		return $self->filter_string($target, $args);
	}
	elsif (ref ($target) eq ref ([]))
	{
		return $self->filter_array($target, $args);
	}
	elsif (ref ($target) eq ref ({}))
	{
		if($target->{'#directive'})
		{
			return $self->filter_directive($target, $args);
		}
		return $self->filter_element($target, $args);
	}
	return undef;
}
1;

