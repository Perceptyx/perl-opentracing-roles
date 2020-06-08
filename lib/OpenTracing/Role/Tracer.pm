package OpenTracing::Role::Tracer;

=head1 NAME

OpenTracing::Role::Tracer - Role for OpenTracin implementations.

=head1 SYNOPSIS

    package OpenTracing::Implementation::MyBackendService::Tracer;
    
    use Moo;
    
    sub start_active_span { ... };
    
    sub start_span { ... };
    
    ...
    
    with 'OpenTracing::Role::Tracer';
    
    1;

=cut



our $VERSION = '0.08_004';



use Moo::Role;

use Carp;
use OpenTracing::Types qw/ScopeManager Span SpanContext/;
use Role::Declare;
use Try::Tiny;
use Types::Common::Numeric qw/PositiveOrZeroNum/;
use Types::Standard qw/HashRef Str/;



=head1 DESCRIPTION

This is a base-class for OpenTracing implenetations that are compliant with the
L<OpenTracing::Interface>.

=cut



has scope_manager => (
    is              => 'ro',
    isa             => ScopeManager,
    reader          => 'get_scope_manager',
    required        => 1,
);



requires 'extract_context';

requires 'inject_context';



sub get_active_span {
    my $self = shift;
    
    my $scope_manager = $self->get_scope_manager
        or croak "Can't get a 'ScopeManager'";
    
    my $scope = $scope_manager->get_active_scope
        or return;
    
    return $scope->get_span;
}



# this is not an OpenTracing API requirement
#
sub get_active_span_context {
    my $self = shift;
    
    my $span_context = try {
        $self->get_active_span->get_context
    } catch {
        return undef
    };
    
    return $span_context
}



sub start_active_span {
    my $self = shift;
    #
    # TODO: croak when even number of arguments, after shifting invocant
    #       first must be a operation name
    #       then key / value pairs
    
    my $operation_name = shift
        or croak "Missing required operation_name";
    my $opts = { @_ };
    #
    # TODO: only check on 'finish_span_on_close'
    #       leave all other checks to 'start_span'
    
    # remove the `finish_span_on_close` option, which is for this method only! 
    my $finish_span_on_close = 
        exists( $opts->{ finish_span_on_close } ) ?
            !! delete $opts->{ finish_span_on_close }
            : !undef
    ; # use 'truthness' of param if provided, or set to 'true' otherwise
    
    my $span = $self->start_span( $operation_name => %$opts );
    #
    # TODO: use 'try { ... } catch { croak }'
    
    my $scope_manager = $self->get_scope_manager();
    
    my $scope = $scope_manager->activate_span( $span,
        finish_span_on_close => $finish_span_on_close
    );
    
    return $scope
}



sub start_span {
    my $self = shift;
    #
    # TODO: croak when even number of arguments, after shifting invocant
    #       first must be a operation name
    #       then key / value pairs
    
    my $operation_name = shift
        or croak "Missing required operation_name";
    my $opts = { @_ };
    
    my $start_time         = delete $opts->{ start_time };
    my $ignore_active_span = delete $opts->{ ignore_active_span };
    my $child_of           = delete $opts->{ child_of };
    my $tags               = delete $opts->{ tags };
    #
    # TODO: croak whit remaining options
    
    $child_of //= $self->get_active_span()
        unless $ignore_active_span;
    
#   $child_of->does(') ?
    
    my $context =
        defined $child_of
        && 
#       $child_of->does('OpenTracing::Interface::SpanContext')
        $child_of->can('with_baggage_item')
        &&
        $child_of->can('get_baggage_item')
        #
        # 'does' does not work, then just check on most essential methods
        # TODO: use OpenTracing::Types
        #
        ?
        $child_of : $self->get_active_span_context();
        #
        # TODO: figure out why we want to get the active span it's context
        #       what if we have passed in a span, should we take it's context?
        #       is it more relevant to have the 'active context' at all times?
    
    my $span = $self->build_span(
        operation_name => $operation_name,
        child_of       => $child_of,
        start_time     => $start_time,
        tags           => $tags,
        context        => $context,
    );
    #
    # we should get rid of passing 'child_of' or the not exisitng 'follows_from'
    # these are merely helpers to define 'references'.
    #
    # TODO: use 'try { ... } catch { croak }'
    
    return $span
}



=head1 REQUIRES

The followin must be implemented by consuming class

=cut



=head2 build_span

=cut

instance_method build_span (
    
    Str                   :$operation_name,
    SpanContext | Span    :$child_of,
    SpanContext | HashRef :$context,
    PositiveOrZeroNum     :$start_time      = undef,
    HashRef[Str]          :$tags            = {},
    
) :Return (Span) { };



BEGIN {
#   use Role::Tiny::With;
    with 'OpenTracing::Interface::Tracer'
        if $ENV{OPENTRACING_INTERFACE};
}



1;