#!/usr/bin/env perl

use Test2::V0;
use lib 'lib';

use Dev::Util::Syntax;
use Dev::Util qw(::OS ::Utils ::File);

use Socket;

plan tests => 1;

#======================================#
#                banner                #
#======================================#

my $expected = <<'EOW';
################################################################################
#                                                                              #
#                                 Hello World                                  #
#                                                                              #
################################################################################

EOW

my $output;
open( my $outputFH, '>', \$output ) or croak;
banner( "Hello World", $outputFH );
close $outputFH;

is( $output, $expected, 'Banner Test' );

#======================================#
#           Make test files            #
#======================================#

my $test_file = 't/perlcriticrc';

my $td = mk_temp_dir();
my $tf = mk_temp_file($td);

my $no_file = '/nonexistant_file';
my $no_dir  = '/nonexistant_dir';

my $tff = $td . "/tempfile.$$.test";
open( my $tff_h, '>', $tff ) or croak "Can't open file for writing\n";
print $tff_h "Owner Persist Iris Seven";
close($tff_h);

my $tsl = $td . "/symlink.$$.test";
symlink( $tff, $tsl );

socket( my $ts, PF_INET, SOCK_STREAM, ( getprotobyname('tcp') )[2] );
my $trf = '/bin/cat';
my $dnf = '/dev/null';

#======================================#
#             display_menu             #
#======================================#

# my $msg    = 'Pick a choice from the list:';
# my @items  = ( 'choice one', 'choice two', 'choice three', 'ab', );
# my $choice = display_menu( $msg, @items );

done_testing;
