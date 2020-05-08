requires            "OpenTracing::Interface", '>= 0.19';
requires            "OpenTracing::Types"; # yes, it is part of Interface'

requires            "Carp";
requires            "Data::GUID";
requires            "Moo::Role";
requires            "MooX::Enumeration";
requires            "MooX::HandlesVia";
requires            "MooX::ProtectedAttributes";
requires            "Sub::Trigger::Lock";
requires            "Time::HiRes";
requires            "Try::Tiny";
requires            "Types::Standard";

on 'test' => sub {
    requires            "Test::Deep", '>= 1.130';
    requires            "Test::Interface";
    requires            "Test::MockObject::Extends";
    requires            "Test::Most";
    requires            "Test::OpenTracing::Interface";
    requires            "Test::Time::HiRes";
    requires            "Test::Warn";
};
