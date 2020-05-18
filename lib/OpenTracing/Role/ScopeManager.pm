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

use Carp;

use Types::Standard qw/CodeRef/;
use OpenTracing::Types qw/Scope/;



=head1 DESCRIPTION

This is a role for OpenTracing implenetations that are compliant with the
L<OpenTracing::Interface>.

=cut

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



sub activate_span {
    my $self = shift;
    my $span = shift or croak "Missing OpenTracing Span";
    
    my $options = { @_ };
    
    my $finish_span_on_close = 
        exists( $options->{ finish_span_on_close } ) ?
            !! delete $options->{ finish_span_on_close }
            : !undef
    ; # use 'truthness' of param if provided, or set to 'true' otherwise
    
    my $scope = $self->scope_builder( $span,
        finish_span_on_close => $finish_span_on_close,
        %$options,
    );
    
    $self->set_active_scope( $scope );
    
    return $scope
}



has scope_builder => (
    is       => 'ro',
    isa      => CodeRef,
    default  => sub { sub {...} },
);



BEGIN {
#   use Role::Tiny::With;
    with 'OpenTracing::Interface::ScopeManager'
        if $ENV{OPENTRACING_INTERFACE};
}



1;
