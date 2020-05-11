use Test::Most;


$ENV{OPENTRACING_INTERFACE} = 1 unless exists $ENV{OPENTRACING_INTERFACE};
#
# This breaks if it would be set to 0 externally, so, don't do that!!!



subtest "Instantiation of Span and Tags" => sub {
    
    # get_tags returns a plain hash, not a hash reference
    
    cmp_deeply(
        {
            MyStub::Span->new(
                operation_name => 'test',
                context        => bless( {}, 'MyStub::SpanContext' ),
                child_of       => bless( {}, 'MyStub::Span' ),
            )->get_tags( )
        },
        { },
        "By default, there are no tags"
    );
    
    cmp_deeply(
        {
            MyStub::Span->new(
                operation_name => 'test',
                context        => bless( {}, 'MyStub::SpanContext' ),
                child_of       => bless( {}, 'MyStub::Span' ),
                tags           => { key1 => 'foo', key2 => 'bar' },
            )->get_tags( )
        },
        {
            key1 => 'foo',
            key2 => 'bar',
        },
        "Tags can be provided at instantiation"
    );
    
};



done_testing();



package MyStub::Span;

use Moo;

BEGIN { with 'OpenTracing::Role::Span' }



package MyStub::SpanContext;

use Moo;

BEGIN { with 'OpenTracing::Role::SpanContext' }



1;
