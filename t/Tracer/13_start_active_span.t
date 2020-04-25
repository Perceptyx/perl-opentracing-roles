use Test::Most;
use Sub::Override;

$ENV{OPENTRACING_INTERFACE} = 1 unless exists $ENV{OPENTRACING_INTERFACE};
#
# This breaks if it would be set to 0 externally, so, don't do that!!!



# we want to capture the arguments passed into `start_span`
# so, we use the role and override the specific method
# and capture them the arguments

my @start_span_arguments;

use OpenTracing::Role::Tracer;

my $override = Sub::Override->new;
$override->replace( 'OpenTracing::Role::Tracer::start_span' =>
    sub {
        my $class = shift;
        
        push @start_span_arguments, [ @_ ];
        
        bless {}, 'MyMock::Span'
    }
);



package MyTest::Tracer;
use Moo;
with 'OpenTracing::Role::Tracer';

# add required subs
#
sub _build_scope_manager { ... }
sub build_span {  }
sub extract_context { ... }
sub inject_context { ... }



package MyMock::Span;
use Moo;
with 'OpenTracing::Role::Span';



package MyMock::SpanContext;
use Moo;
with 'OpenTracing::Role::SpanContext';
with 'OpenTracing::Interface::SpanContext';



package MyMock::Scope;
use Moo;
with 'OpenTracing::Role::Scope';

sub close { $_[0]->_set_closed( !undef); $_[0] }



package MyMock::ScopeManager;

use Moo;

with 'OpenTracing::Role::ScopeManager';

sub activate_span { bless {}, 'MyMock::Scope' }
sub get_active_scope { ... }



package main;

my $mock_scope_manager = bless {}, 'MyMock::ScopeManager';
my $mock_span_context  = bless {}, 'MyMock::SpanContext';

my $test_tracer = MyTest::Tracer->new(
    scope_manager => $mock_scope_manager,
);

lives_ok {
    $test_tracer
        ->start_active_span( 'my_operation_name',
            ignore_active_span => 1,
            child_of           => $mock_span_context,
            start_time         => 1.25,
            tags               => { foo => 1, bar => 6 },
        )
        ->close;
    
    $test_tracer
        ->start_active_span( 'my_operation_next',
            finish_span_on_close => 0,
        )->close;
} "Can call 'start_active_span'";

is( shift @{ $start_span_arguments[0] }, 'my_operation_name',
    "... and pass from 'start_active_span' to 'start_span' the 'operation name'"
);

cmp_deeply(
    { @{$start_span_arguments[0]} },
    {
        ignore_active_span => 1,
        child_of           => $mock_span_context,
        start_time         => 1.25,
        tags               => { foo => 1, bar => 6 },
    },
    "... and pass remaining options"
);

is( shift @{ $start_span_arguments[1] }, 'my_operation_next',
    "... and pass from 'start_active_span' to 'start_span' the 'operation next'"
);

cmp_deeply(
    { @{$start_span_arguments[1]} },
    { },
    "... and pass not 'finish_span_on_close'"
);

#print "@start_span_arguments\n";

done_testing();



1;
