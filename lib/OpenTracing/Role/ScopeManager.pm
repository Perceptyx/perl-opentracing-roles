package OpenTracing::Role::ScopeManager;

=head1 NAME

OpenTracing::Role::ScopeManager - Role for OpenTracing implementations.

=head1 SYNOPSIS

    package OpenTracing::Implementation::MyBackendService::ScopeManager;
    
    use Moo;
    
    with 'OpenTracing::Role::ScopeManager'
    
    sub activate_span { ... }
    
    sub get_active_scope { ... }
    
    1;

=cut



our $VERSION = '0.08_001';



use Moo::Role;



=head1 DESCRIPTION

This is a role for OpenTracing implenetations that are compliant with the
L<OpenTracing::Interface>.

=cut



requires 'activate_span';
# The chosen design is to have only 1 active scope and use callback to change
# what the 'previous' scope would be when we close a scope.
#
# An other design could be building a stack, using 'push/pop' to keep track of
# which one to activate on close.
#
has _active_scope => (
    is => 'rwp',
    isa => Scope,
    init_arg => undef,
    reader => 'get_active_scope',
    writer => 'set_active_scope',
);









BEGIN {
#   use Role::Tiny::With;
    with 'OpenTracing::Interface::ScopeManager'
        if $ENV{OPENTRACING_INTERFACE};
}



1;
