#!/usr/bin/env perl

use Test2::V0;
use Test2::Require::AuthorTesting;

use Dev::Util::Syntax;

use Test2::Require::Module 'Test::EOL';
use Test::EOL;

# use FindBin;
# use File::Spec;

# use Path::This qw($THISDIR);
# use Path::Tiny;

# my $fs1 = File::Spec->catdir($FindBin::Bin);
# my $fs2 = File::Spec->catdir( $FindBin::Bin, File::Spec->updir );
# my $fs3 = File::Spec->catdir( $FindBin::Bin, File::Spec->updir,
#                               File::Spec->updir );

# diag $fs1;
# diag $fs2;
# diag $fs3;

# my $tf= $THISDIR . '/..';
# diag $tf;

# my $pt = Path::Tiny->cwd;
# diag $pt;
# exit;
# chdir( File::Spec->catdir( $FindBin::Bin, File::Spec->updir ) );

all_perl_files_ok( grep { -e $_ } qw( bin lib t examples Makefile.PL ) );

done_testing;
