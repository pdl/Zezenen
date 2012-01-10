use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Parse::Zezenen::RecDescent',
    AUTHOR              => q{Daniel Perrett <perrettdl@googlemail.com>},
    VERSION_FROM        => 'lib/Parse/Zezenen/RecDescent.pm',
    ABSTRACT_FROM       => 'lib/Parse/Zezenen/RecDescent.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Parse-Zezenen-RecDescent-0.01-*' },
);
