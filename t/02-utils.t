#!/usr/bin/env perl

use Test2::V0;
use lib 'lib';

use Dev::Util::Syntax;
use Dev::Util qw(::OS ::Utils ::File);

use Socket;

plan tests => 20;

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
#                valid                 #
#======================================#

my @valid    = qw (bee bat bear);
my $okempty  = 1;
my $good_str = 'bat';
my $bad_str  = 'snake';

is( valid($good_str), undef,
    'valid - no valid criteria given returns undef' );
is( valid( '', \@valid, $okempty ),
    1, 'valid - empty string with okempty given returns true' );
is( valid( '', \@valid, 0 ),
    undef, 'valid - empty string without okempty given returns undef' );
is( valid( $good_str, \@valid, $okempty ),
    1, 'valid - good string with okempty given returns true' );
is( valid( $good_str, \@valid, 0 ),
    1, 'valid - good string without okempty given returns true' );
is( valid( $bad_str, \@valid, $okempty ),
    0, 'valid - bad string with okempty given returns false' );
is( valid( $bad_str, \@valid, 0 ),
    0, 'valid - bad string without okempty given returns false' );

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
#              stat_date               #
#======================================#

system("touch -t  202402201217.23 $tf");
my $expected_date = '20240220';
my $file_date     = stat_date($tf);
is( $file_date, $expected_date, "stat_date - default daily case" );

$expected_date = '2024/02/20';
$file_date     = stat_date( $tf, 1 );
is( $file_date, $expected_date, "stat_date - dir_format daily case" );

$expected_date = '202402';
$file_date     = stat_date( $tf, 0, 'monthly' );
is( $file_date, $expected_date, "stat_date - default monthly case" );

$expected_date = '2024/02';
$file_date     = stat_date( $tf, 1, 'monthly' );
is( $file_date, $expected_date, "stat_date - dir_format monthly case" );

#======================================#
#              status_for              #
#======================================#

my $file_mtime = status_for($tf)->{ mtime };
is( $file_mtime, '1708449443', 'status_for - mtime of file' );

#======================================#
#             display_menu             #
#======================================#

# my $msg    = 'Pick a choice from the list:';
# my @items  = ( 'choice one', 'choice two', 'choice three', 'ab', );
# my $choice = display_menu( $msg, @items );

#======================================#
#              ipc_run_l               #
#======================================#

my $hw_expected = "hello world";
my @hw          = ipc_run_l( { cmd => 'echo hello world' } );
my $hw_result   = join "\n", @hw;
is( $hw_result, $hw_expected, 'ipc_run_l - echo hello world' );

my $hw_ref = ipc_run_l( { cmd => 'exho hello world' } );
is( $hw_ref, undef, 'ipc_run_l - fail bad cmd: exho hello world' );

my @expected_seq = qw(1 2 3 4 5 6 7 8 9 10);
my @seq          = ipc_run_l( { cmd => 'seq 1 10', } );
is( @seq, @expected_seq, 'ipc_run_l - multiline output' );

#======================================#
#              ipc_run_s               #
#======================================#

my $buf = '';
ok( ipc_run_s( { cmd => 'echo hello world', buf => \$buf } ) );
is( $buf, $hw_expected . "\n", 'ipc_run_s - hellow world' );

ok( !ipc_run_s( { cmd => 'exho hello world', buf => \$buf } ) );

$buf = '';
ok( ipc_run_s( { cmd => 'seq 1 10', buf => \$buf } ) );

done_testing;
