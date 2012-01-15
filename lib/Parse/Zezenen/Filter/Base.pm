package Parse::Zezenen::Filter::Base;
use 5.006;
use strict;
use warnings;

=head1 NAME

Parse::Zezenen::Filter::Base

=cut

sub new
{
	my ($class) = @_ ;
	bless ({}, $class);
}
sub filter_string
{
	my ($self, $target, $args) = @_;
	return $target;
}
sub filter_array
{
	my ($self, $target, $args) = @_;
	my @interpreted = map {$self->filter($_,$args)} @$target;
	return $self->array_merge_text_nodes(\@interpreted,$args);
}
sub filter_element
{
	my ($self, $target, $args) = @_;
	return $self->copy_and_filter_children($target, $args);
}
sub filter_directive
{
	my ($self, $target, $args) = @_;
	return $self->copy_and_filter_children($target, $args);
}
sub array_merge_text_nodes
{
	my ($self, $target, $args) = @_;
	my @interpreted = @{$target};
	my @new;
	foreach my $i (0..$#interpreted)
	{
		if (
			$i > 0
			and ( ref  ($interpreted[$i])  eq ref ('') )
			and ( ref ($interpreted[ $i - 1 ]) eq ref ('') )
		)
		{
			$new[-1] .= $interpreted[$i];
		}
		else
		{
			push @new, $interpreted[$i];
		}
	}
	return [@new];
}
sub copy_and_filter_children
{
	my ($self, $target, $args) = @_;
	my $new = {};
	foreach my $key (keys %$target)
	{
		if ($key eq '~')
		{
			$new->{'~'} = $self->filter($target->{'~'}, $args);
		}
		else
		{
			$new->{$key} = $target->{$key};
		}
	}
	return $new;
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

