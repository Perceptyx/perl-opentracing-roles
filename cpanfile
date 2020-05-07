requires            "OpenTracing::Interface", '>= 0.19';

requires            "Carp";
requires            "Data::GUID";
requires            "Moo::Role";
requires            "MooX::Enumeration";
requires            "MooX::HandlesVia";
requires            "MooX::ProtectedAttributes";
requires            "Sub::Trigger::Lock";
requires            "Time::HiRes";
requires            "Try::Tiny";
requires            "Types::Interface";
requires            "Types::Standard";

on 'test' => sub {
    requires            "Test::Deep", '>= 1.130';
    requires            "Test::Most";
    requires            "Test::MockObject::Extends";
    requires            "Test::Warn";
    requires            "Test::Interface";
    requires            "Test::OpenTracing::Interface";
};
