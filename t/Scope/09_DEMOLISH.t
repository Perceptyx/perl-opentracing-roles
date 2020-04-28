use Test::Most;
use Test::Warn;



subtest "Manual DEMOLISH" => sub {
    
    my $test_obj = new_ok('MyTest::Scope');
    
    ok not( $test_obj->closed ),
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
        my $test_obj = new_ok('MyTest::Scope');
    } qr/Scope not programmatically closed before being demolished/,
        "... and will croak when going out of scope if not closed";
    
    warnings_are {
        my $test_obj = new_ok('MyTest::Scope');
        $test_obj->close();
    } [],
        "... and does not send warnings if closed before DEMOLISH";
    
};



done_testing();



package MyTest::Scope;

use Moo;

# add required subs
#
sub close { $_[0] }
sub get_span { ... }

BEGIN { with 'OpenTracing::Role::Scope'; }



1;
