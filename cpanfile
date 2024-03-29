requires            "OpenTracing::Interface", '>= 0.206.1';
requires            "OpenTracing::Types"; # yes, it is part of Interface'

requires            "Carp";
requires            "Data::GUID";
requires            "List::Util";
requires            "Moo::Role";
requires            "MooX::Enumeration";
requires            "MooX::HandlesVia";
requires            "MooX::ProtectedAttributes";
requires            "MooX::Should", '>=v0.1.4';
requires            "Ref::Util";
requires            "Role::Declare::Should";
requires            "Sub::Trigger::Lock";
requires            "Time::HiRes";
requires            "Try::Tiny";
requires            "Types::Common::Numeric";
requires            "Types::Standard";
requires            "Types::TypeTiny";

on 'test' => sub {
    requires            "Devel::StrictMode";
    requires            "Moo";
    requires            "Test::Deep", '>= 1.130';
    requires            "Test::Interface";
    requires            "Test::MockObject::Extends";
    requires            "Test::Most";
    requires            "Test::OpenTracing::Interface";
    requires            "Test::Time::HiRes";
    requires            "Test::Warn";
};
