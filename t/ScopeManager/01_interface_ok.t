use Test::Most;
use Test::Interface;

=head1 DESCRIPTION

Test that a class that consumes the role, it complies with OpenTracing Interface

=cut

use strict;
use warnings;


$ENV{OPENTRACING_INTERFACE} = 1 unless exists $ENV{OPENTRACING_INTERFACE};
#
# This breaks if it would be set to 0 externally, so, don't do that!!!



package MyStub;
use Moo;

sub build_scope { ... };

with 'OpenTracing::Role::ScopeManager';



package main;

interface_ok('MyStub', 'OpenTracing::Interface::ScopeManager');

done_testing();
