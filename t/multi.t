use Test::More qw/no_plan/;

use FindBin;
use lib "$FindBin::Bin/lib";

use Path::Class;

use Test::Schema;

use Media::Mogul;

my $schema = Test::Schema->init_schema;
my $rs = $schema->resultset('Asset');

my $mm = Media::Mogul->new(
    stores => [
        'Simple' => { 
            root => Path::Class::dir("$FindBin::Bin/var"),
            ignore_meta => 1 # Don't store meta
        },
#        'MogileFS' => {
#            domain  => "cartionary.com",
#            hosts   => [ 'tengu:7001' ],
#            class   => 'user_media'
#        },
        'DBIC'   => { 
            resultset => $rs,
        }
    ]
);

my $metadata = { 
    'person_id'   => 1,
    'description' => 'Simple Test' 
};

my $data = 'I am pretty in pink', # Or $fh

my $uuid = $mm->store( metadata => $metadata, data => $data );

my $obj = $mm->fetch( $uuid );

ok($obj, 'fetched simple object');
is( $obj->mime, 'text/plain', 'default content type');
is_deeply($obj->metadata, $metadata, 'metadata restored');
is_deeply($obj->data, $data, 'data together');


