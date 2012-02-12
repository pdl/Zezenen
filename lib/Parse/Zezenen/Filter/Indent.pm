package Parse::Zezenen::Filter::Indent;
use 5.006;
use strict;
use warnings;
use base "Parse::Zezenen::Filter::Base";

=head1 NAME

Parse::Zezenen::Filter::Indent

=cut

sub filter_string
{
	my ($self, $target, $args) = @_;
	$args ||={'indentlevel'=>0, 'indentchar'=>' '};
	unless ($args->{'PRE'})
	{
		$target =~ s/(?:\\r\\n|\\n|\\r)[\\t\\x20]*//g;
		$target =~ s/\s+/ /g;
	}
	return $target;
}
sub filter_array
{
	my ($self, $target, $args) = @_;
	$args ||={'indentlevel'=>1, 'indentchar'=>' '};
	my @interpreted;
	my $merged = $self->array_merge_text_nodes($target,$args);
	if ($#{$merged} > -1)
	{
		foreach my $node (map {$self->filter($_,$args)} @$merged)
		{
			push @interpreted, _make_indent($args);
			push @interpreted, $node;
		}
		push @interpreted, _make_indent({%$args, 'indentlevel'=>$args->{'indentlevel'}-1});
		return $self->array_merge_text_nodes(\@interpreted,$args);
	}
	return [];
}
sub filter_directive
{
	my ($self, $target, $args) = @_;
	$args ||={'indentlevel'=>0, 'indentchar'=>' '};
	if($target->{'#name'} eq 'PRE')
	{
		$self->copy_and_filter_children($target, {%$args, 'PRE'=>1, 'indentlevel'=>$args->{'indentlevel'} +1});
	}
	return $self->copy_and_filter_children($target, {%$args, 'indentlevel'=>$args->{'indentlevel'} +1});
}
sub filter_element
{
	my ($self, $target, $args) = @_;
	$args ||={'indentlevel'=>0, 'indentchar'=>' '};
	if($target->{'#name'} eq 'PRE')
	{
		$self->copy_and_filter_children($target, {%$args, 'PRE'=>1, 'indentlevel'=>$args->{'indentlevel'} +1});
	}
	return $self->copy_and_filter_children($target, {%$args, 'indentlevel'=>($args->{'indentlevel'} +1)});
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
sub _make_indent
{
	my ($args) = @_;
	if (defined $args->{'indentlevel'} and defined $args->{'indentchar'})
	{
		return "\n". ($args->{'indentchar'} x $args->{'indentlevel'})
	}
	return '';
}

1;
