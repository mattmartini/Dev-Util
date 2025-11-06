#!/usr/bin/env perl

use Test2::V0;
use lib 'lib';

use Dev::Util::Syntax;
use Dev::Util::Const;
## use Dev::Util::Const qw(:named_constants);

use Socket;

plan tests => 5;

my $emt_str = q{};
my $sp      = q{ };
my $sq      = q{'};
my $dq      = q{"};
my $comm    = q{,};

is( $EMPTY_STR,    $emt_str, 'empty string' );
is( $SPACE,        $sp,      'empty string' );
is( $SINGLE_QUOTE, $sq,      'empty string' );
is( $DOUBLE_QUOTE, $dq,      'empty string' );
is( $COMMA,        $comm,    'empty string' );

done_testing;

