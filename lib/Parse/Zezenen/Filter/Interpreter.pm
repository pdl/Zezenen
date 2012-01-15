package Parse::Zezenen::Filter::Interpreter;
use 5.006;
use strict;
use warnings;
use base Parse::Zezenen::Filter::Interpreter;

=head1 NAME

Parse::Zezenen::Filter::Interpreter

=cut

sub filter_string
{
	my ($self, $target, $args) = @_;
	unless ($args->{'PRE'})
	{
		$target =~ s/(?:\\r\\n|\\n|\\r)[\\t\\x20]*//g;
		$target =~ s/\s+/ /g;
	}
	return $target;
}
sub filter_directive
{
	my ($self, $target, $args) = @_;
	if($target->{'#name'} eq 'U')
	{
		if (ref ($target->{'~'}) eq ref ([]))
		{
			my $sCPs = join ('',@{$target->{'~'}}); # TODO: Test if we're not concatenating strings with hashes.
			if ($sCPs =~ m/^[a-zA-Z0-9\s\n\r\t]+$/)
			{
				return join ('', 
					map { chr( hex( $_ ) ) } split(/[\n\s\t]+/,$sCPs)
				);
			}
			else
			{
				return undef;
			}
		}
		else
		{
			return undef;
		}
	}
	elsif($target->{'#name'} eq 'PRE')
	{
		return $self->interpret($target->{'~'}, {%$args, 'PRE'=>1});
	}

	return $self->copy_and_filter_children($target, $args);
}

