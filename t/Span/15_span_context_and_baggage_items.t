use Test::Most;



subtest "Set a single baggage_item" => sub {
    
    my $span_context_1;
    my $span_context_2;
    my $test_span;
    
    lives_ok {
        $span_context_1 = MyStub::SpanContext->new(
            baggage_items => {
                item_1 => 'foo',
            },
        );
    } "Instantiated a SpanContext [1] with a baggage_item [item_1]"
    
    or return;
    
    lives_ok {
        $test_span = MyStub::Span->new(
            operation_name  => 'test',
            context         => $span_context_1,
            child_of        => bless {}, 'MyStub::SpanContext',
        );
    } "... and used it to instantiate a new test Span"
    
    or return;
    
    lives_ok {
        $test_span->set_baggage_item( item_2 => 'bar' );
    } "Did set a new baggage item [item_2]"
    
    or return;
        
    lives_ok {
        $span_context_2 = $test_span->get_context;
    } "Got a SpanContext [2]"
    
    or return;
    
    isnt $span_context_1, $span_context_2,
        "... that is not the same object reference as the original";
    
    is $test_span->get_baggage_item( 'item_1' ), 'foo',
        "... and 'get_baggage_item' returns the correct value for [item_1]";
    
    is $test_span->get_baggage_item( 'item_2' ), 'bar',
        "... and 'get_baggage_item' returns the correct value for [item_2]";
    
};



done_testing();



package MyStub::Span;
use Moo;

BEGIN { with 'OpenTracing::Role::Span'; }



package MyStub::SpanContext;
use Moo;

BEGIN { with 'OpenTracing::Role::SpanContext'; }



1;
