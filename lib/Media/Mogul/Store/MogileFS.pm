package Media::Mogul::Store::MogileFS::Object;

use Moose;
use MooseX::Storage;

use Carp;

with Storage( format => 'JSON', io => 'MogileFS' );

has 'client' => (
    metaclass => 'DoNotSerialize',
    is  => 'rw',
    isa => 'MogileFS::Client'
);

has 'data' => (
    is  => 'rw',
    isa => 'HashRef'
);

has 'mime' => (
    is  => 'rw',
    isa => 'Str'
);

1;

package Media::Mogul::Store::MogileFS;

use Moose;
use MooseX::Storage;

extends 'Media::Mogul::Store::Base';

use MogileFS::Client;

use Carp;

has 'domain' => (
    is  => 'rw',
    isa => 'Str',
    required => 1
);

has 'class' => (
    is  => 'rw',
    isa => 'Str',
    required => 1
);

has 'hosts' => (
    is  => 'rw',
    isa => 'ArrayRef',
    required => 1
);

has 'client' => (
    is  => 'rw',
    isa => 'MogileFS::Client',
    lazy => 1,
    default => sub { 
        my $self = shift; 
        MogileFS::Client->new( hosts => $self->hosts, domain => $self->domain );
    }
);

sub store {
    my ( $self, $obj ) = @_;

    my $id = $obj->uuid;
    unless ( $id ) { 
        my $gen = $self->id_generator;
        croak "Can't use this store, no ID generator present and object has no UUID" unless $gen;
        $obj->uuid( $gen->( $self, $obj ) );
        $id = $obj->uuid;
    }
    croak "Failed generating UUID for object" unless $id;

    my $mime_type = $obj->mime . "";
    foreach my $key ( qw/metadata data original/ ) {
        my $data = $obj->$key;
        next unless defined $data;
        my $storable = Media::Mogul::Store::MogileFS::Object->new(
            client => $self->client,
            data => { data => $data }, 
            mime => $mime_type
        );
        $storable->store( $self->class, "$id:$key" );
    }

    return $id;
}

sub fetch {
    my ( $self, $id ) = @_;

    my %bits = ( uuid => $id );

    foreach my $key ( qw/metadata data original/ ) {
        my $bit = eval {
            Media::Mogul::Store::MogileFS::Object
                ->load( $self->client, "$id:$key" );
        };
        next unless defined $bit;
        $bits{$key} = $bit->data->{data};
        $bits{mime} = MIME::Types->new->type($bit->mime) 
            if $bit->mime and not $bits{mime};
    }
    # Need at least the data key to continue.
    croak "Unable to locate $id in store" unless defined $bits{data};
    return Media::Mogul::Object->new( %bits );
}


1;
