package Media::Mogul::Store::Simple::Object;

use Moose;
use MooseX::Storage;

use Carp;

with Storage( format => 'JSON', io => 'File' );

has 'data' => (
    is  => 'rw',
    isa => 'HashRef'
);

has 'mime' => (
    is  => 'rw',
    isa => 'Str'
);

1;

package Media::Mogul::Store::Simple;

use Carp;

use Moose;
use Moose::Util::TypeConstraints;
use Path::Class;
use JSON::XS;

extends 'Media::Mogul::Store::Base';

subtype 'Path' 
    => as 'Object'
    => where { $_->isa('Path::Class::Dir') }
;

coerce 'Path' 
    => from 'Object'
        => via { 
                $_->isa('URI::file') ?
                    Path::Class::dir( $_->dir )
                    : croak "Can't coerce $_ into Path object";
            }
    => from 'Str'
        => via { Path::Class::dir( $_ ); }
;

has 'root' => (
    is  => 'rw',
    isa => 'Path',
    #default => sub { Path::Class::dir } # Defaults to cwd
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

    my $root      = $self->root;
    my $mime_type = $obj->mime . "";
    foreach my $key ( qw/metadata data original/ ) {
        my $data = $obj->$key;
        next unless defined $data;
        my $storable = Media::Mogul::Store::Simple::Object->new(
            data => { data => $data }, 
            mime => $mime_type
        );
        $storable->store( $root->file("$id:$key")->stringify );
    }

    return $id;
}

sub fetch {
    my ( $self, $id ) = @_;

    my %bits = ( uuid => $id );
    my $root = $self->root;

    foreach my $key ( qw/metadata data original/ ) {
        my $bit = eval {
            Media::Mogul::Store::Simple::Object->load(
                $root->file("$id:$key")->stringify 
            );
        };
        next if $@ and $@ =~ /Unable to open file/;
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
