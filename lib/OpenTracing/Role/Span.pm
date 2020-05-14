package OpenTracing::Role::Span;

=head1 NAME

OpenTracing::Role::Span - Role for OpenTracing implementations.

=head1 SYNOPSIS

    package OpenTracing::Implementation::MyBackendService::Span;
    
    use Moo;
    
    ...
    
    with 'OpenTracing::Role::Span'
    
    1;

=cut



our $VERSION = '0.07';



use Moo::Role;
use MooX::HandlesVia;

use Carp;
use Data::GUID;
use Time::HiRes qw/time/;
use Types::Standard qw/HashRef Num Object Str Value/;
use OpenTracing::Types qw/:types :is/;



=head1 DESCRIPTION

This is a Role for OpenTracing implenetations that are compliant with the
L<OpenTracing::Interface>.

With the exception of calls to C<get_context()> (which are always allowed),
C<finish()> must be the last call made to any span instance, and to do otherwise
leads to undefined behavior (but not returning an exception).

=cut



has span_id => (
    is              => 'ro',
#   isa             => Uuid, # not restraints here, do so when consuming this
    init_arg        => undef,
    default         => sub { Data::GUID->new },
);



has operation_name => (
    is              => 'rwp',
    isa             => Str,
    required        => 1,
#   writer          => 'overwrite_operation_name',
    reader          => 'get_operation_name', # it's not in the Interface
);



has start_time => (
    is              => 'ro',
    isa             => Num,
    default         => sub { epoch_floatingpoint() }
);



has finish_time => (
    is              => 'rwp',
    isa             => Num,
    predicate       => 'has_finished',
    init_arg        => undef,
);



has tags => (
    is              => 'rwp',
    isa             => HashRef[Value],
    handles_via     => 'Hash',
    handles         => {
        get_tags => 'all',
    },
    default         => sub{ {} },
);



has context => (
    is              => 'ro',
    isa             => SpanContext,
    reader          => 'get_context',
#   writer          => '_set_context',
    required        => 1, # either from Span->get_context or SpanContext self
);



sub overwrite_operation_name {
    my $self = shift;
    
    croak "Can't overwrite an operation-name on an already finished span"
        if $self->has_finished;
    
    my $operation_name = shift; # or throw an exception
    
    $self->_set_operation_name( $operation_name );
    
    return $self
}



sub finish {
    my $self = shift;
    
    croak "Span has already been finished"
        if $self->has_finished;
    
    my $epoch_timestamp = shift // epoch_floatingpoint();
    
    $self->_set_finish_time( $epoch_timestamp );
    
    return $self
}



sub set_tag {
    my $self = shift;
    
    croak "Can't set a tag on an already finished span"
        if $self->has_finished;
    
    my $key = shift;
    my $value = shift;
    
    $self->set_tags( $key => $value );
    
    return $self
}



sub set_tags {
    my $self = shift;
    
    croak "Can't set a tag on an already finished span"
        if $self->has_finished;
    
    my %tags = @_;
    $self->_set_tags(
        { $self->get_tags, %tags }
    );
    
    return $self
}



sub log_data {
    my $self = shift;
    
    croak "Can't log any more data on an already finished span"
        if $self->has_finished;
    
    my %log_data = @_;
    
#   ... # shall we just use Log::Any ?
    
    return $self
}



sub set_baggage_item {
    my $self = shift;
    
    croak "Can't set baggage-items on an already finished span"
        if $self->has_finished;
    
    my $key = shift;
    my $value = shift;
    
    $self->set_baggage_items( $key => $value );
    
    return $self
}



sub set_baggage_items {
    my $self = shift;
    
    croak "Can't set baggage-items on an already finished span"
        if $self->has_finished;
    
    my %items = @_;
    
    my $new_context = $self->get_context()->with_baggage_items( %items );
    $self->_set_context( $new_context );
    
    return $self
}



sub get_baggage_item {
    my $self = shift;
    my $key = shift;
    
    return $self->get_context()->get_baggage_item( $key )
}



sub get_baggage_items {
    my $self = shift;
    
    return $self->get_context()->get_baggage_items
}



sub duration { 
    my $self = shift;
    
    my $start_time = $self->{ start_time }
        or croak
            "Span has not been started: ['"
            .
            ( $self->operation_name || "'undef'" )
            .
            "'] ... how did you do that ?";
    my $finish_time = $self->{ finish_time }
        or croak
            "Span has not been finished: ['"
            .
            ( $self->operation_name || "'undef'" )
            .
            "'] ... yet!";
    
    return $finish_time - $start_time
}



has child_of => (
    is => 'ro',
    isa =>Object, # does Span or does SpanContext
    required => 1,
);



sub parent_span_id {
    my $self = shift;
    
    my $parent = $self->{ child_of };
    return unless is_Span( $parent );
    
    return $parent->span_id
}
#
# This may not be the right way to implement it, for the `child_of` attribute
# may not be such a good idea, maybe it should use references, but not sure how
# those are used



# _set_context
#
# you really shouldn't change the context yourself, only on instantiation
#
sub _set_context {
    my $self = shift;
    
    croak "Can't set context on an already finished span"
        if $self->has_finished;
    
    my $context = shift or die "Missing context";
    
    $self->{ context } = $context;
    
    return $self
}



=head2 epoch_floatingpoint

Well, returns the time since 'epoch' with fractional seconds, as floating-point.

=cut

sub epoch_floatingpoint {
    return time()
}
#
# well, this is a bit off a silly idea:
# some implentations may want nano-second accuracy, but floating point
# computations using 64bits (IEEE) are only having 16 digits in the mantissa.
# The number of nano-seconds since epoch is 19 digits that barely fits in a
# signed 64 bit integer.



BEGIN {
#   use Role::Tiny::With;
    with 'OpenTracing::Interface::Span'
        if $ENV{OPENTRACING_INTERFACE};
}



1;


