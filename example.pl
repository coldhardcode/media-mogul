use Media::Mogul;

# 
# *********** THIS IS PSEUDO-CODE, IT DOES NOT ACTUALLY RUN ****************
#


# CREATE THE PROCESSORS
# NOTE: If 'types' isn't a regular expression, parse the values like Moose types
#
# Discover the mime type if not specified.  Handle 'undef' types
my $mime   = Media::Mogul::Processor::MIME::Type->new( types => undef );

# The following use regular expressions.  Anything with a type of "image" goes
# through this step
my $image  = Media::Mogul::Processor::Image->new( types => qr/^image/ );

# Lingua::Inspect to determine the language, run this on text documents or
# email (MIME::Entity) objects.
my $lingua = Media::Mogul::Processor::Lingua->new( 
    types => [ qr/^text/, 'MIME::Entity', 'MIME::Body' ] 
);

# Type to handle a defined MIME::Entity object.  
my $email  = Media::Mogul::Processor::Email->new( types => 'MIME::Entity' );

# CREATE THE STORES
# You have to store the data in multiple locations (or rather, different views
# and perspectives of the data.  DBIC would only store the UUID and links to
# customer records, the KinoSearch store would store the plain text index.
# MogileFS or Simple store the actual file data.
my $ind    = Media::Mogul::Store::KinoSearch->new(
    types => [ qr/^text/, 'MIME::Entity', 'MIME::Body' ] 
);
my $mog    = Media::Mogul::Store::MogileFS->new( $mogile );
my $dbic   = Media::Mogul::Store::DBIC->new( 
    # Create a new record
    connect_info => [ @connect_info ],
    # Or, you can just pass in schema:
    # schema => $schema,
    class        => 'Media',
    id_column    => 'id',
    # Simple, just a random UUID
    id_generator => sub { UUID::Random::generate },
    # Or, something better, generate an MD5 sum of the data block
    id_generator => sub { Digest::MD5::md5_base64( $shift->data ); }
);

# id_generator runs if there is no $obj->uuid set
my $simple = Media::Mogul::Store::Simple->new( 
    root => '.',
    # Simple, just a random UUID
    id_generator => sub { UUID::Random::generate },
    # Or, something better, generate an MD5 sum of the data block
    id_generator => sub { Digest::MD5::md5_base64( $shift->data ); }
);

my $schema = $dbic->schema; # DTRT, returns a connected schema.
$schema->resultset('Media')->search({ name => 'foo.jpg' });

my $mm;

$mm = Media::Mogul->new( 
    # Stores and Processors are called in the order listed.

    stores => [ $dbic ], # Start with just a DBIC store.  
                         # This will lose file data.
    # All the processors, each processor will only do things with supported 
    # content types (from the MIME, and $mime detects mime type if not specified
    # already).
    processors => [ 
        $mime,
        $lingua,
        $email
        $image,
    ]
);

# Can be an Imager object, Image::Magick or just a hash.  DBIC Store doesn't
# store data, so on its own you can't get the data back out now.  Fairly useless
$mm->process( { filename => 'foo.jpg', data => $image }, 'image/jpg' );

# Ok, so now a simple store will store it on disk.  DBIC -must- be first because
# it generates the UUID.  If there is no UUID by the time it gets to simple,
# one is generated and DBIC will have to use that (and the id_generator method
# above is useless).
$mm->stores( $dbic, $simple );

# Test we can pull it from FS, and that it doesn't duplicate records in the 
# stores.
{
    my $rs = $schema->resultset('Media')->search({ name => 'foo.jpg' })
    is($rs->count, '==', 1);
    my $record = $rs->first;
    my $obj = $mm->fetch( $record->id );

    $obj->mime; # MooseX::Mime or just a MIME::Type object?
    $obj->data; # Raw image data
    $obj->meta; # EXIF?
    $obj->meta->{language}; # Should be undef
    $obj->original;

    # Simple service:
    # print "Content-type: " . $obj->mime->content_type . "\r\n";
    # print $obj->data;
}
