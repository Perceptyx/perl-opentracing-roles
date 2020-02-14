use Test::Most;
use Test::Warn;

package MyTestClass;

use Moo;

with 'OpenTracing::Role::Scope';

# add required subs
#
sub close {
}

sub get_span { ... }



package main;

subtest "Manual DEMOLISH" => sub {
    my $test_obj = new_ok('MyTestClass');
    
    ok ! ( $test_obj->closed ),
        "... and has not been closed yet";
    
    throws_ok {
        $test_obj->DEMOLISH( 1 );
    } qr/Scope not programmatically closed before being demolished/,
        "... and will croak if not closed properly";
    
    lives_ok {
        $test_obj->close( )
    }
        "... can do a close";
    
    lives_ok {
        $test_obj->DEMOLISH( 1 );
    }
        "... and will quietly DEMOLISH";
    
    undef $test_obj;
};



subtest "End Of Scope DEMOLISH" => sub {
    
   
    warning_like {
        my $test_obj = new_ok('MyTestClass');
    } qr/Scope not programmatically closed before being demolished/,
        "... and will croak when going out of scope if not closed";
    
    warnings_are {
        my $test_obj = new_ok('MyTestClass');
        $test_obj->close();
    } [],
        "... and does not send warnings if closed before DEMOLISH";
    
};



done_testing();

