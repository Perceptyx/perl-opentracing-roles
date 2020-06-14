requires            "OpenTracing::Interface", '>= 0.18, <0.202.0';

requires            "Carp";
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
    requires            "Sub::Override";
    requires            "Test::Most";
    requires            "Test::Interface";
    requires            "Test::OpenTracing::Interface";
};
