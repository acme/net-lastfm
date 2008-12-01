#!perl
use strict;
use warnings;
use ExtUtils::MakeMaker;
WriteMakefile(
    NAME         => 'Net::LastFM',
    VERSION_FROM => 'lib/Net/LastFM.pm',
    AUTHOR       => 'Leon Brocard <acme@astray.com>',
    ABSTRACT     => 'Call the Last.fm API',
    LICENSE      => 'perl',
    PREREQ_PM    => {
        'Digest::MD5'               => '0',
        'LWP::UserAgent'            => '0',
        'Moose'                     => '0',
        'MooseX::StrictConstructor' => '0',
        'URI::QueryParam'           => '0',
        'XML::Simple'               => '0',
    }
);

