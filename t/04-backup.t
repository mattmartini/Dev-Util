#!/usr/bin/env perl

use Test2::V0;
use lib 'lib';

use MERM::Base::Syntax;
use MERM::Base qw(::Utils ::Backup);

# plan tests => 6;

#======================================#
#           Make test files            #
#======================================#

my $td = mk_temp_dir();
my $tf = mk_temp_file($td);

my $tff = $td . "/tempfile.$$.test";
open( my $tff_h, '>', $tff ) or croak "Can't open file for writing\n";
print $tff_h "Powerful Tiny Turn Related Flew";
close($tff_h);

#======================================#
#                backup                #
#======================================#

my $mtime = ( stat $filename )[9];
my ( $mday, $mon, $year ) = ( localtime($mtime) )[ 3 .. 5 ];

$newfile = $basefile
    = sprintf( "%s_%d%02d%02d", $filename, $year + 1900, $mon + 1, $mday );

# my $expected_host = qx(hostname);
# chomp($expected_host);
# my $host = get_hostname();
# is( $host, $expected_host, "get_hostname - matches hostname" );

# $expected_host = qx(uname -n);
# chomp($expected_host);
# is( $host, $expected_host, "get_hostname - matches uname -n" );

is( 1, 1 );

done_testing;
