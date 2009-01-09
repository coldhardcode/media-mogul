use Test::More qw/no_plan/;

use Media::Mogul::Store::DBIC;
use Media::Mogul::Object;

use FindBin;
use lib "$FindBin::Bin/lib";

use Test::Schema;

my $schema = Test::Schema->init_schema;
ok($schema, 'got schema');

my $rs = $schema->resultset('Asset');
ok(defined $rs, 'got resultset');

my $store = Media::Mogul::Store::DBIC->new( resultset => $rs );
ok($store, 'created dbic store');

my $obj = Media::Mogul::Object->new(
    uuid     => $store->id_generator->(),
    metadata => { 'description' => 'Simple Test' },
    data     => 'I am pretty in pink'
);

ok($obj, 'created simple object');
is($obj->mime, 'text/plain', 'is just text/plain');

my $id;
ok($id = $store->store( $obj ), 'stored object');
my $fetch_obj = $store->fetch($id);
is( $fetch_obj->mime, $obj->mime, 'same content type');
is( $fetch_obj->data, undef, 'data not stored in dbic object');
is_deeply( $fetch_obj->metadata, $obj->metadata, 'metadata the same');



