use 5.006;
use strict;
use warnings FATAL => 'all';
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Mojolicious::Plugin::ConfigRoutes',
    license             => 'perl',
    dist_author         => q{Mikhail Che <mche@aukama.dyndns.org>},
    dist_version_from   => 'lib/Mojolicious/Plugin/ConfigRoutes.pm',
    release_status      => 'stable',
    configure_requires => {
        'Module::Build' => 0,
    },
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        #'ABC'              => 1.6,
        'Mojolicious' => 3.79,
    },
    add_to_cleanup     => [ 'Mojolicious-Plugin-ConfigRoutes-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
