package MooseX::Storage::Engine::IO::MogileFS;

use Carp;
use Moose;

our $VERSION = '0.01';

has 'key' => (
    is  => 'ro',
    isa => 'Str',
    required => 1
);

has 'client' => (
    is  => 'ro',
    isa => 'MogileFS::Client',
    required => 1
);


sub load {
    my ( $self ) = @_;
    my $ref = $self->client->get_file_data($self->key);
    if ( defined $ref ) {
        return $$ref;
    }
    die "No data for " . $self->key;
}

sub store {
    my ( $self, $class, $data ) = @_;
    my $len   = $self->client->store_content($self->key, $class, $data);
    unless ( defined $len ) {
        croak "Failed storing data in cluster: " . $self->client->errstr;
    }
    return $len;
}

1;

