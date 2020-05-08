use Test::Most;


$ENV{OPENTRACING_INTERFACE} = 1 unless exists $ENV{OPENTRACING_INTERFACE};
#
# This breaks if it would be set to 0 externally, so, don't do that!!!



use Test::Time::HiRes time => 256.875;

my $test_span;

$test_span = MyStub::Span->new(
    operation_name => 'test',
    context        => bless( {}, 'MyStub::SpanContext' ),
    start_time     => 0,
    child_of       => bless( {}, 'MyStub::Span' ),
);

Test::Time::HiRes->set_time( 512.125 );

$test_span->finish( );

is $test_span->finish_time +0, 512.125,      # Test::Time::HiRes returns a string
    "... and has the correct finish_time";


done_testing();



package MyStub::Span;

use Moo;

BEGIN { with 'OpenTracing::Role::Span' }



package MyStub::SpanContext;

use Moo;

BEGIN { with 'OpenTracing::Role::SpanContext' }



1;
