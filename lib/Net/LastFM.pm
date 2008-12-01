package Net::LastFM;
use Moose;
use MooseX::StrictConstructor;
use Digest::MD5 qw(md5_hex);
use LWP::UserAgent;
use URI::QueryParam;
use XML::Simple qw(:strict);
our $VERSION = '0.32';

has 'api_key' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has 'api_secret' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has 'ua' => (
    is       => 'rw',
    isa      => 'LWP::UserAgent',
    required => 0,
    default  => sub {
        my $ua = LWP::UserAgent->new;
        $ua->agent( 'Net::LastFM/' . $VERSION );
        $ua->env_proxy;
        return $ua;
    }
);

my $ROOT = 'http://ws.audioscrobbler.com/2.0/';

sub request {
    my ( $self, %conf ) = @_;
    my $ua = $self->ua;

    $conf{api_key} = $self->api_key;
    my $uri = URI->new('http://ws.audioscrobbler.com/2.0/');

    foreach my $key ( keys %conf ) {
        my $value = $conf{$key};
        $uri->query_param( $key, $value );
    }

    my $request = HTTP::Request->new( 'GET', $uri );

    my $response = $ua->request($request);

    my $data = XMLin( $response->content, ForceArray => 0, KeyAttr => [] );

    if ( $data->{status} eq 'ok' ) {
        return $data;
    } else {
        my $code    = $data->{error}->{code};
        my $content = $data->{error}->{content};
        confess "$code: $content";
    }
}

sub request_signed {
    my ( $self, %conf ) = @_;
    $conf{api_key} = $self->api_key;

    my $to_hash = '';
    foreach my $key ( sort keys %conf ) {
        my $value = $conf{$key};
        $to_hash .= $key . $value;
    }
    $to_hash .= $self->api_secret;
    $conf{api_sig} = md5_hex($to_hash);

    return $self->request(%conf);
}

1;

__END__

=head1 NAME

Net::LastFM - A simple interface to the Last.fm API

=head1 SYNOPSIS

  my $lastfm = Net::LastFM->new(
      api_key    => 'XXX',
      api_secret => 'YYY',
  );
  my $data = $lastfm->request_signed(
      method => 'user.getRecentTracks',
      user   => 'lglb',
  );

=head1 DESCRIPTION

The module provides a simple interface to the Last.fm API. To use
this module, you must first sign up at L<http://www.last.fm/api>
to receive an API key and secret.

You can then make requests on the API - most of the requests
are signed. You pass in a hash of paramters and a data structure
mirroring the response is returned.

This module confesses if there is an error.

=head1 METHODS

=head2 request

This makes an unsigned request:

  my $data = $lastfm->request( method => 'auth.gettoken' );

=head2 request_signed

This makes a signed request:

  my $data = $lastfm->request_signed(
      method => 'user.getRecentTracks',
      user   => 'lglb',
  );

=head1 AUTHOR

Leon Brocard <acme@astray.com>

=head1 COPYRIGHT

Copyright (C) 2008, Leon Brocard.

=head1 LICENSE

This module is free software; you can redistribute it or 
modify it under the same terms as Perl itself.
