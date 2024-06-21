use Test::More tests => 3;

BEGIN {
use_ok( 'MERM::Base' );
use_ok( 'MERM::Base::Syntax' );
use_ok( 'MERM::Base::Utils' );
}

diag( "Testing MERM::Base $MERM::Base::VERSION" );
