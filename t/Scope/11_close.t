use Test::Most;

BEGIN {
    $ENV{OPENTRACING_INTERFACE} = 1 unless exists $ENV{OPENTRACING_INTERFACE};
}
#
# This breaks if it would be set to 0 externally, so, don't do that!!!

=head1 DESCRIPTION

Test that a class that consumes the role, it complies with OpenTracing Interface

=cut

use strict;
use warnings;


our @close_arguments;

package MyTestClass;

use Moo;

with 'OpenTracing::Role::Scope';

# add required subs
#
sub close {
    push @main::close_arguments, [ @_ ];
    
    my $self = shift;
    
    return $self;
}

sub get_span { ... }



package main;

my $test_obj = new_ok('MyTestClass');

ok ! ( $test_obj->closed ),
    "... and has not been closed yet";

lives_ok {
    $test_obj->close( )
} "... can do a close";

cmp_deeply(
    [ @close_arguments ] => [
        [ obj_isa('MyTestClass') ],
    ],
    "... our 'close' only receives the object itself"
);

ok $test_obj->closed,
    "... and has now been closed";

throws_ok {
    $test_obj->close( )
} qr/Can't close an already closed scope/,
    "... and can not close again";

cmp_deeply(
    [ @close_arguments ] => [
        ignore,
    ],
    "... our 'close' has not been called more than once"
);


done_testing();
