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



our $VERSION = '0.08_005';



use Moo::Role;

use Carp;
use OpenTracing::Types qw/ScopeManager Span SpanContext is_Span is_SpanContext/;
use Ref::Util qw/is_plain_hashref/;
use Role::Declare;
use Try::Tiny;
use Types::Common::Numeric qw/PositiveOrZeroNum/;



=head1 DESCRIPTION

This is a base-class for OpenTracing implenetations that are compliant with the
L<OpenTracing::Interface>.

=cut


use Types::Standard qw/HashRef Object Str/;

has scope_manager => (
    is              => 'ro',
    isa             => ScopeManager,
    reader          => 'get_scope_manager',
    default => sub {
        require 'OpenTracing::Implementation::NoOp::ScopeManager';
        return OpenTracing::Implementation::NoOp::ScopeManager->new
    },
);

has default_span_context_args => (
    is              => 'ro',
    isa             => HashRef[Str],
    default         => sub{ {} },
);

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
    
    my $context;

    $context = $child_of
        if is_SpanContext($child_of);
    
    $context = $child_of->get_context
        if is_Span($child_of);
    
    $context = $context->new_clone->with_trace_id( $context->trace_id )
        if is_SpanContext($context);
    
    $context = $self->build_context( %{$self->default_span_context_args} )
        unless defined $context;
    
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

instance_method extract_context(
    Str    $carrier_format,
    Object $carrier
) :ReturnMaybe(SpanContext) {}


=head1 REQUIRES

The followin must be implemented by consuming class

=cut



=head2 build_span
instance_method inject_context(
    Str    $carrier_format,
    Object $carrier,
    SpanContext $span_context
) :Return(Object) {}

=cut

instance_method build_span (
    Str                :$operation_name,
    SpanContext | Span :$child_of,
    SpanContext        :$context,
    PositiveOrZeroNum  :$start_time      = undef,
    HashRef[Str]       :$tags            = {},
) :Return (Span) { };

instance_method build_context (
    %default_span_context_args,
) :Return (SpanContext) {
    ( HashRef[Str] )->assert_valid( { %default_span_context_args } );
};



BEGIN {
#   use Role::Tiny::With;
    with 'OpenTracing::Interface::Tracer'
        if $ENV{OPENTRACING_INTERFACE};
}



1;