use Test::More qw/no_plan/;

use FindBin;

use Media::Mogul::Store::Simple;
use Media::Mogul::Object;

my $store = Media::Mogul::Store::Simple->new( root => Path::Class::dir("$FindBin::Bin/var") );
ok($store, 'created simple store');

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



