use Test::Most;
use Test::MockObject::Extends;


=for comments:

Test that:
- given a ScopeManager
- given a Acitve Scope
- given a related Span

we do return that Span, `undef` otherwise

=cut



done_testing();



# MyStub::...
#
# The following packages are stubs with minimal implementation that only
# satisfy required subroutines so roles can be applied.
# Any subroutines under testing probably need mocking
# Test::MockObject::Extends is your friend

package MyStub::Tracer;
use Moo;

sub _build_scope_manager { ... }
sub build_span           { ... }
sub extract_context      { ... }
sub inject_context       { ... }

BEGIN { with 'OpenTracing::Role::Tracer'; }



package MyStub::Span;
use Moo;

BEGIN { with 'OpenTracing::Role::Span'; }



package MyStub::Scope;
use Moo;

sub close { $_[0]->_set_closed( !undef); $_[0] }

BEGIN { with 'OpenTracing::Role::Scope'; }



package MyStub::ScopeManager;
use Moo;

sub activate_span { ... }
sub get_active_scope { ... }

BEGIN { with 'OpenTracing::Role::ScopeManager'; }






1;
