use Test::Most;


$ENV{OPENTRACING_INTERFACE} = 1 unless exists $ENV{OPENTRACING_INTERFACE};
#
# This breaks if it would be set to 0 externally, so, don't do that!!!



my $test_span;
my $start_time = time();

$test_span = MyStub::Span->new(
    operation_name => 'test',
    context        => bless( {}, 'MyStub::SpanContext' ),
    start_time     => 0,
    child_of       => bless( {}, 'MyStub::Span' ),
);

$test_span->finish( );

# note, perl time works with integers, the Span object should work with floats
#
ok( between( $test_span->finish_time, $start_time, $start_time +1 ),
    "Span finished within 1 second"
);



done_testing();



sub between {
    return ($_[0] >= $_[1]) && ($_[0] <= $_[2])
}



package MyStub::Span;

use Moo;

BEGIN { with 'OpenTracing::Role::Span' }



package MyStub::SpanContext;

use Moo;

BEGIN { with 'OpenTracing::Role::SpanContext' }



1;
