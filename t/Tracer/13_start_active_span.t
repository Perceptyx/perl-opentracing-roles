use Test::Most;
use Sub::Override;
use Test::Deep qw/true false/;
use Test::MockObject::Extends;

$ENV{OPENTRACING_INTERFACE} = 1 unless exists $ENV{OPENTRACING_INTERFACE};
#
# This breaks if it would be set to 0 externally, so, don't do that!!!


my $mock_span_context  = bless {}, 'MyMock::SpanContext';
my $mock_span          = bless {}, 'MyMock::Span';

# mock the methods we're interested in
#
my $mock_scope_manager = Test::MockObject::Extends->new(
    MyMock::ScopeManager->new()
)->mock( 'activate_span' =>
    sub { bless {}, 'MyMock::Scope' }
);

my $mock_tracer = Test::MockObject::Extends->new(
    MyTest::Tracer->new(
        scope_manager => $mock_scope_manager,
    )
)->mock( 'start_span' =>
    sub {
        $mock_span
    }
);



subtest "Pass through to 'start_span' with known options" => sub {
    
    my ($self, $call_name, $call_args);
    
    $mock_tracer->clear();
    $mock_scope_manager->clear();
    
    
    
    lives_ok {
        $mock_tracer
            ->start_active_span( 'some operation name',
                ignore_active_span   => 1,
                child_of             => $mock_span_context,
                start_time           => 1.25,
                tags                 => { foo => 1, bar => 6 },
                finish_span_on_close => 1,
            )->close;
    } "Can call 'start_active_span' with known options";
    
    
    
    ($call_name, $call_args) = $mock_tracer->next_call();
    
    is( $call_name, 'start_span',
        "... and did pass on to 'start_span'"
    );
    
    is( shift @{$call_args}, $mock_tracer,
        "... with the invocant is the 'MyMock::Tracer'"
    );
    
    is( shift @{$call_args}, "some operation name",
        "... with the operation_name as first argument"
    );
    
    cmp_deeply(
        { @{$call_args} },
        {
            ignore_active_span => 1,
            child_of           => $mock_span_context,
            start_time         => 1.25,
            tags               => { foo => 1, bar => 6 },
        },
        "... with the expected remaining options"
    ); # that is, without 'finish_span_on_close, see below
    
};



subtest "Pass through to 'start_span' without any options" => sub {
    
    my ($self, $call_name, $call_args);
    
    $mock_tracer->clear();
    $mock_scope_manager->clear();
    
    
    
    lives_ok {
        $mock_tracer
            ->start_active_span( 'next operation name',
        )->close;
    } "Can call 'start_active_span' without any options";
    
    ($call_name, $call_args) = $mock_tracer->next_call();
    
    is( $call_name, 'start_span',
        "... and did pass on to 'start_span'"
    );
    
    is( shift @{$call_args}, $mock_tracer,
        "... with the invocant is the 'MyMock::Tracer'"
    );
    
    is( shift @{$call_args}, "next operation name",
        "... with the operation_name as first argument"
    );
    
    cmp_deeply(
        { @{$call_args} },
        { },
        "... without introducing default options"
    );
    
};

subtest "Private option 'finish_span_on_close'" => sub {
    
    my ($self, $call_name, $call_args);
    
    $mock_tracer->clear();
    $mock_scope_manager->clear();
    
    
    
    lives_ok {
        $mock_tracer
            ->start_active_span( 'this operation name',
        )->close;
    } "Can call 'start_active_span' without 'finish_span_on_close'";
    
    ($call_name, $call_args) = $mock_scope_manager->next_call();
    
    is( $call_name, 'activate_span',
        "... and did pass on to 'activate_span'"
    );
    
    is( shift @{$call_args}, $mock_scope_manager,
        "... with the invocant is the 'MyMock::ScopeManager'"
    );
    
    is( shift @{$call_args}, $mock_span,
        "... with the 'MyMock::Span' from previous call"
    );
    
    cmp_deeply(
        { @{$call_args} },
        {
            finish_span_on_close => true,
        },
        "... with default 'finish_span_on_close' set to 'true'"
    );
    
    
    
    lives_ok {
        $mock_tracer
            ->start_active_span( 'that operation name',
            finish_span_on_close => 1,
        )->close;
    } "Can call 'start_active_span' with 'finish_span_on_close' set to 'true'";
    
    ($call_name, $call_args) = $mock_scope_manager->next_call();
    
    shift @{$call_args}; # invocant
    shift @{$call_args}; # span
    
    cmp_deeply(
        { @{$call_args} },
        {
            finish_span_on_close => true,
        },
        "... with pass on 'finish_span_on_close' set to 'true'"
    );
    
    
    
    lives_ok {
        $mock_tracer
            ->start_active_span( 'last operation name',
            finish_span_on_close => 0,
        )->close;
    } "Can call 'start_active_span' with 'finish_span_on_close' set to 'false'";
    
    ($call_name, $call_args) = $mock_scope_manager->next_call();
    
    shift @{$call_args}; # invocant
    shift @{$call_args}; # span
    
    cmp_deeply(
        { @{$call_args} },
        {
            finish_span_on_close => false,
        },
        "... with pass on 'finish_span_on_close' set to 'false'"
    );
   
};



done_testing();



package MyTest::Tracer;
use Moo;

# add required subs
#
sub _build_scope_manager { ... }
sub build_span           { ... }
sub extract_context      { ... }
sub inject_context       { ... }

BEGIN { with 'OpenTracing::Role::Tracer'; }



package MyMock::Span;
use Moo;

BEGIN { with 'OpenTracing::Role::Span'; }



package MyMock::SpanContext;
use Moo;

BEGIN { with 'OpenTracing::Role::SpanContext'; }



package MyMock::Scope;
use Moo;

sub close { $_[0]->_set_closed( !undef); $_[0] }

BEGIN { with 'OpenTracing::Role::Scope'; }



package MyMock::ScopeManager;
use Moo;

sub activate_span { ... }
sub get_active_scope { ... }

BEGIN { with 'OpenTracing::Role::ScopeManager'; }






1;
