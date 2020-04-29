use Test::Most;
use Test::OpenTracing::Interface::ScopeManager qw/can_all_ok/;

use strict;
use warnings;

can_all_ok('MyStub::ScopeManager');

done_testing();


package MyStub::ScopeManager;
use Moo;

sub activate_span    { ... }
sub get_active_scope { ... }

BEGIN { with 'OpenTracing::Role::ScopeManager' }
