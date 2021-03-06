use Test::Most tests => 1;
use Test::Deep qw/true false/;
use Test::MockObject::Extends;

=head1 DESCRIPTION

Check that we do get back the C<ScopeManager> we used at instantiation.

=cut

$ENV{EXTENDED_TESTING} = 1 unless exists $ENV{EXTENDED_TESTING};
#
# This breaks if it would be set to 0 externally, so, don't do that!!!


subtest "Get the original 'ScopeManager'" => sub {
    
    plan tests => 1;
    
    my ($call_name, $call_args);
    
    my $some_scope_manager = MyStub::ScopeManager->new;
    
    my $test_tracer = MyStub::Tracer->new(
        scope_manager => $some_scope_manager,
    );
    
    is $test_tracer->get_scope_manager(), $some_scope_manager,
        "The returned 'scope_manager' is the expected on"
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

sub build_span                           { ... }
sub build_context                        { ... }
sub inject_context_into_array_reference  { ... }
sub extract_context_from_array_reference { ... }
sub inject_context_into_hash_reference   { ... }
sub extract_context_from_hash_reference  { ... }
sub inject_context_into_http_headers     { ... }
sub extract_context_from_http_headers    { ... }

BEGIN { with 'OpenTracing::Role::Tracer'; }



package MyStub::ScopeManager;
use Moo;

sub build_scope { ... };

BEGIN { with 'OpenTracing::Role::ScopeManager'; }



1;
