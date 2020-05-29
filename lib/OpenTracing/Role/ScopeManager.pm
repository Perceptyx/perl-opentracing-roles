package OpenTracing::Role::ScopeManager;

=head1 NAME

OpenTracing::Role::ScopeManager - Role for OpenTracing implementations.

=head1 SYNOPSIS

    package OpenTracing::Implementation::MyBackendService::ScopeManager;
    
    use Moo;
    
    with 'OpenTracing::Role::ScopeManager'
    
    1;

=cut



our $VERSION = '0.08_002';



use Moo::Role;

use Carp;

use Types::Standard qw/Bool CodeRef Dict Maybe/;
use OpenTracing::Types qw/Scope Span assert_Scope/;
use Role::Declare;



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



=head1 REQUIRED METHODS



=head2 C<build_scope>

This method should return a C<Scope>

=head3 Expected Named Parameters

=over

=item C<span>

A OpenTracing compliant C<Span> object.

=item C<finish_span_on_close>

A C<Bool> type.

=back

=head3 Note

Unlike the OpenTracing API interface specification, C<build_scope> does not let
it up for discusion, C<span> and C<finish_span_on_close> are expected named
parameters.

=cut


instance_method build_scope (
    
    Span :$span,
    Bool :$finish_span_on_close
    
) :Return ( Scope ) { };



=head1 INSTANCE METHODS

=cut



=head2 activate_span

Sets the given C<$span> as being the active span in a newly created C<Scope>.

=head3 Required Positional Parameter

=over

=item C<$span>

A OpenTracing compliant C<Span> object.

=back

=head3 Optional Named Parameter

=over

=item C<finish_span_on_close>

A C<Bool> type, that decides wether or not C<finish> gets called on the C<$span>
object. Defaults to 'true'.

=back

=head3 Note

This is part of a proposed API change.

=cut

sub activate_span {
    my $self = shift;
    my $span = shift or croak "Missing OpenTracing Span";
    
    my $options = { @_ };
    
    my $finish_span_on_close = 
        exists( $options->{ finish_span_on_close } ) ?
            !! delete $options->{ finish_span_on_close }
            : !undef
    ; # use 'truthness' of param if provided, or set to 'true' otherwise
    
    my $scope = $self->build_scope(
        span                 => $span,
        finish_span_on_close => $finish_span_on_close,
        %$options,
    );
    
    $self->set_active_scope( $scope );
    
    return $scope
}



BEGIN {
#   use Role::Tiny::With;
    with 'OpenTracing::Interface::ScopeManager'
        if $ENV{OPENTRACING_INTERFACE};
}



1;
