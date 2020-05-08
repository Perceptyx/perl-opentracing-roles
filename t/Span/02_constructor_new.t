use Test::Most;


$ENV{OPENTRACING_INTERFACE} = 1 unless exists $ENV{OPENTRACING_INTERFACE};
#
# This breaks if it would be set to 0 externally, so, don't do that!!!


package MyTest::Span;
use Test::Time::HiRes time => 256.875;

use Moo;

with 'OpenTracing::Role::Span';



package MyTest::SpanContext;

use Moo;

with 'OpenTracing::Role::SpanContext';



package main;

my $test_span;

lives_ok {
    $test_span = MyTest::Span->new(
        operation_name => 'test',
        context        => bless( {}, 'MyTest::SpanContext' ),
        child_of       => bless( {}, 'MyTest::Span' ),
    );
} "Can create new 'Span'";

is $test_span->start_time +0, 256.875,      # Test::Time::HiRes returns a string
    "... and has the correct start_time";



done_testing();






1;
