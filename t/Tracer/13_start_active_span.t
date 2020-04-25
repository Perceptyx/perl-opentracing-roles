use Test::Most;
use Sub::Override;

$ENV{OPENTRACING_INTERFACE} = 1 unless exists $ENV{OPENTRACING_INTERFACE};
#
# This breaks if it would be set to 0 externally, so, don't do that!!!



# we want to capture the arguments passed into `start_span`
# so, we use the role and override the specific method
# and capture them the argument

my @start_span_arguments;

use OpenTracing::Role::Tracer;

my $override = Sub::Override->new;
$override->replace( 'OpenTracing::Role::Tracer::start_span' =>
    sub {
        my $class = shift;
        
        @start_span_arguments = @_;
        
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

);

$test_tracer->start_active_span( 'my_operation_name', ignore_active_span => 1 )
    ->close;

cmp_deeply(
    \@start_span_arguments,
    [
        'my_operation_name',
        ignore_active_span => 1
    ],
    "Passes on the right arguments from 'start_active_span' to 'start_span'"
);

#print "@start_span_arguments\n";

done_testing();



1;
