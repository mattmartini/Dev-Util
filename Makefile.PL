use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
               NAME             => 'MERM::Base',
               AUTHOR           => 'Matt Martini <matt@imaginarywave.com>',
               VERSION_FROM     => 'lib/MERM/Base.pm',
               ABSTRACT_FROM    => 'lib/MERM/Base.pm',
               LICENSE          => 'gpl_3',
               MIN_PERL_VERSION => '5.018',
               PL_FILES         => {},
               PREREQ_PM        => {
                              'Test::More' => 0,
                              'version'    => 0,
                            },
               dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
               clean => { FILES    => 'MERM-Base-*' },
             );
