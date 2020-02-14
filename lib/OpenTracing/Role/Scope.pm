package OpenTracing::Role::Scope;

=head1 NAME

OpenTracing::Role::Scope - Role for OpenTracing implementations.

=head1 SYNOPSIS

    package OpenTracing::Implementation::MyBackendService::Scope;
    
    use Moo;
    
    with 'OpenTracing::Role::Scope'
    
    sub close => { ... }
    
    1;

=cut



our $VERSION = 'v0.70.1';



use Moo::Role;

use Types::Interface qw/ObjectDoesInterface/;
use Types::Standard qw/Bool/;

use Carp;



=head1 DESCRIPTION

This is a Role for OpenTracing implenetations that are compliant with the
L<OpenTracing::Interface>.

=cut



has span => (
    is => 'ro',
    isa => ObjectDoesInterface['OpenTracing::Interface::Span'],
    reader => 'get_span',
);



has finish_span_on_close => (
    is => 'ro',
    isa => Bool,
);



has closed => (
    is              => 'rwp',
    isa             => Bool,
    init_arg        => undef,
    default         => !!undef,
);



around close => sub {
    my $orig = shift;
    my $self = shift;
    
    croak "Can't close an already closed scope"
        if $self->closed;
    
    $self->_set_closed( !undef );
    
    $self->get_span->finish
        if $self->finish_span_on_close;
    
    $orig->( $self => @_ );
#   return $self->get_scope_manager()->deactivate_scope( $self );
    
};



sub DEMOLISH {
    my $self = shift;
    my $in_global_destruction = shift;
    
    return if $self->closed;
    
    croak "Scope not programmatically closed before being demolished";
    #
    # below might be appreciated behaviour, but you should close yourself
    #
    $self->close( )
        unless $in_global_destruction;
    
    return
}



BEGIN {
    use Role::Tiny::With;
    with 'OpenTracing::Interface::Scope'
        if $ENV{OPENTRACING_INTERFACE};
}



1;
