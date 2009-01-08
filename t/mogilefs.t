use Test::More qw/no_plan/;

use FindBin;

use Media::Mogul::Store::MogileFS;
use Media::Mogul::Object;

my $store = Media::Mogul::Store::MogileFS->new(
    domain  => "cartionary.com",
    hosts   => [ 'tengu:7001' ],
    class   => 'user_media'
);

isa_ok($store, 'Media::Mogul::Store::MogileFS', 'created store');
isa_ok($store->client, 'MogileFS::Client', 'mogilefs client');

my $obj = Media::Mogul::Object->new(
    metadata => { 'foo' => 'bar' },
    data     => 'I am pretty in pink'
);    
ok($obj, 'created simple object');
is($obj->mime, 'text/plain', 'is just text/plain');

my $id;
ok($id = $store->store( $obj ), 'stored object');
diag($id);
my $fetch_obj = $store->fetch($id);
is( $fetch_obj->mime, $obj->mime, 'same content type');
is_deeply( $fetch_obj->data, $obj->data, 'same object');

