use Test::Most;



done_testing();



package MyStub::SpanContext;
use Moo;

BEGIN { with 'OpenTracing::Role::SpanContext'; }



1;
