use Test::Most;
use Test::OpenTracing::Interface::ScopeManager qw/can_all_ok/;

use strict;
use warnings;

can_all_ok('MyStub::ScopeManager');

done_testing();


package MyStub::ScopeManager;
use Moo;

BEGIN { with 'OpenTracing::Role::ScopeManager' }
