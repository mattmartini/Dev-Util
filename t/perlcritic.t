#!/usr/bin/env perl

use Test2::V0;
use Test2::Require::AuthorTesting;

use Dev::Util::Syntax;

use FindBin qw($RealBin);

# perlcritic config set in this file
local $ENV{ PERLCRITIC } = $RealBin . '/perlcriticrc';

eval {
    require Test::Perl::Critic;
    import Test::Perl::Critic;
    1;
} or do {
    plan( skip_all => 'Test::Perl::Critic required to criticise code' );
};

Test::Perl::Critic::all_critic_ok();
