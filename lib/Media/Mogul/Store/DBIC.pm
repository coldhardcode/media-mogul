package Media::Mogul::Store::DBIC;

use Moose;

use Scalar::Util 'blessed';

extends 'Media::Mogul::Store::Base';

use Carp;

has 'resultset' => (
    is  => 'rw',
    isa => 'DBIx::Class::ResultSet',
    required => 1
);

has 'id_column' => (
    is  => 'rw',
    isa => 'Str',
    default => 'uuid'
);

has 'mime_type_column' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'mime_type'
);

has 'prefetch' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { { } }
);

=head2 Adding related records

If the metadata has a structure like:

    {
        'person_id' => 1,
        'history'   => [
            { ... },
        ]
    }

And the resultset has a relationship called 'history', then this store will
iterate over history and insert each record

=cut


sub store {
    my ( $self, $obj ) = @_;

    my $id = $obj->uuid;
    unless ( $id ) { 
        croak "Can't use this store, object must have UUID prior to storage";
    }

    my $metadata  = $obj->metadata;
    my $mime_type = $obj->mime . "";

    my @columns = $self->resultset->result_source->columns;
   
    $metadata->{$self->id_column}        ||= $id;
    $metadata->{$self->mime_type_column} ||= $mime_type;

    my $data = { }; 

    foreach my $col ( @columns ) {
        next unless exists $metadata->{$col};
        $data->{$col} = $metadata->{$col};
    }

    my $row = $self->resultset->create($data);
    die "Failed create record for $id!" unless $row;

    return $id;
}

sub fetch {
    my ( $self, $id ) = @_;

    my %bits = ( uuid => $id );

    my $rs = $self->resultset->search(
        { %bits }, 
        { prefetch => $self->prefetch }
    );
    $rs->result_class('DBIx::Class::ResultClass::HashRefInflator');
    my $row = $rs->first;

    croak "Unable to locate $id in store" unless defined $row;

    if ( my $mime = $row->{$self->mime_type_column} ) {
        $bits{mime} = $mime;
    }
    $bits{metadata} = $row;
    #TODO: Shoudl this be a coercion, or perhaps a DBIx::Class inflatecol?
    $bits{mime}     = MIME::Types->new->type($bits{mime})
        unless blessed $bits{mime} and $bits{mime}->isa('MIME::Type');

    return Media::Mogul::Object->new( %bits );
}


1;
