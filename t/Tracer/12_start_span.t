use Test::Most tests => 1;
use Test::Deep qw/true false/;
use Test::MockObject::Extends;

=head1 DESCRIPTION

Check that this role does all the munging and prepating before calling
C<build_span>

=head1 WARNING

This test is incomplete, far from complete. Reason for this is that the
interface description, and the usage of C<ContextReference> is unclear and not
implemented.

This needs to be revisited once this is role has been refactored.

=cut

$ENV{OPENTRACING_INTERFACE} = 1 unless exists $ENV{OPENTRACING_INTERFACE};
#
# This breaks if it would be set to 0 externally, so, don't do that!!!

# Test that `start_span` is doing the right thing
#
# considder:
#
# - ignore_active_span ()
# - references (which we do not have yet)
# - child_of (some context)
# - follows_from (not OpenTracing API ?)
#
# also, rethink about 'operation_name' being a named parameter or not
# YES, we want things explicit!



# Hmmmm....
#
# We either have or don't have a 'child_of'
#
# - if we have one, (Span or SpanContext) then
#   - pass on the child given
#   - if it is a Span, we need to get it's SpanContext
#   - pass on the SpanContext

# TODO: wait for the 'reference' attribute or however it will be defined
#       The current API description is bad and it uses 'shortcuts' like
#       'child_of' to create a ContextReference.


subtest "Pass through to 'build_span' with known options" => sub {
    
    plan tests => 4;
    
    my ($self, $call_name, $call_args);
    
    my $mock_tracer = Test::MockObject::Extends->new(
        MyStub::Tracer->new(
            scope_manager => bless {}, 'MyStub::ScopeManager',
        )
    )->mock( 'build_span' =>
        sub { bless {}, 'MyStub::Span' }
    );
    
    my $some_span_context  = bless {}, 'MyStub::SpanContext';
    
    
    
    lives_ok {
        $mock_tracer
            ->start_span( 'some operation name',
                ignore_active_span   => 1,
                child_of             => $some_span_context,
                start_time           => 1.25,
                tags                 => { foo => 1, bar => 6 },
            );
    } "Can call 'start_span' with known options"
    
    or return;
    
    
    ($call_name, $call_args) = $mock_tracer->next_call();
    
    is( $call_name, 'build_span',
        "... and did pass on to 'build_span'"
    );
    
    is( shift @{$call_args}, $mock_tracer,
        "... with the invocant is the 'MyMock::Tracer'"
    );
    
    cmp_deeply(
        { @{$call_args} },
        {
            operation_name     => 'some operation name',
            child_of           => $some_span_context,
            start_time         => 1.25,
            tags               => { foo => 1, bar => 6 },
            context            => $some_span_context,
        },
        "... with the expected pre-processed options"
    );
    
};



done_testing();



# MyStub::...
#
# The following packages are stubs with minimal implementation that only
# satisfy required subroutines so roles can be applied.
# Any subroutines under testing probably need mocking
# Test::MockObject::Extends is your friend

package MyStub::Tracer;
use Moo;

sub build_span          { ... }
sub extract_context     { ... }
sub inject_context      { ... }

BEGIN { with 'OpenTracing::Role::Tracer'; }



package MyStub::Span;
use Moo;

BEGIN { with 'OpenTracing::Role::Span'; }



package MyStub::SpanContext;
use Moo;

BEGIN { with 'OpenTracing::Role::SpanContext'; }



package MyStub::ScopeManager;
use Moo;

BEGIN { with 'OpenTracing::Role::ScopeManager'; }






1;
