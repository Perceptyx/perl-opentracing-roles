use ExtUtils::MakeMaker::CPANfile;

WriteMakefile(
    'NAME'          => 'OpenTracing::Role',
    'VERSION_FROM'  => 'lib/OpenTracing/Role.pm',
    'LICENSE'       => 'perl',
    test            => {
        TESTS       => 't/*.t t/*/*.t',
    },
);
