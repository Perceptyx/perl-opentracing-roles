use Test::Most;
use Test::OpenTracing::Interface::Tracer qw/can_all_ok/;

use strict;
use warnings;

can_all_ok('MyStub::Tracer');

done_testing();


package MyStub::Tracer;
use Moo;

sub _build_scope_manager { ... }
sub build_span           { ... }
sub extract_context      { ... }
sub inject_context       { ... }

BEGIN { with 'OpenTracing::Role::Tracer' }
