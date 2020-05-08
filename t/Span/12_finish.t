use Test::Most;


$ENV{OPENTRACING_INTERFACE} = 1 unless exists $ENV{OPENTRACING_INTERFACE};
#
# This breaks if it would be set to 0 externally, so, don't do that!!!



use Test::Time::HiRes;



subtest "Default behaviour" => sub {
    
    my $test_span;
    
    $test_span = MyStub::Span->new(
        operation_name => 'test',
        context        => bless( {}, 'MyStub::SpanContext' ),
        child_of       => bless( {}, 'MyStub::Span' ),
    );
    
    Test::Time::HiRes->set_time( 256.875 );
    
    lives_ok {
        $test_span->finish( );
    } "Can finish a Span without timestamp";
    
    is $test_span->finish_time +0, 256.875,
        "... and has the correct finish_time";
    
};



subtest "Explicit finish time" => sub {
    
    my $test_span;
    
    $test_span = MyStub::Span->new(
        operation_name => 'test',
        context        => bless( {}, 'MyStub::SpanContext' ),
        child_of       => bless( {}, 'MyStub::Span' ),
    );
    
    Test::Time::HiRes->set_time( 256.875 );
    
    lives_ok {
        $test_span->finish( 128.125 );
    } "Can finish a Span without explicit timestamp";
    
    is $test_span->finish_time +0, 128.125,
        "... and has the correct finish_time";
    
};



done_testing();



package MyStub::Span;

use Moo;

BEGIN { with 'OpenTracing::Role::Span' }



package MyStub::SpanContext;

use Moo;

BEGIN { with 'OpenTracing::Role::SpanContext' }



1;
