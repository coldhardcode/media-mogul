package Test::Schema::Asset;

use parent 'DBIx::Class';

__PACKAGE__->load_components('Core');
__PACKAGE__->table('asset');

__PACKAGE__->add_columns(
    'uuid',
    {
        data_type   => 'CHAR',
        size        => 37,
        is_nullable => 0
    },
    'mime_type',
    {
        data_type   => 'VARCHAR',
        size        => 64,
        is_nullable => 0
    },
    'person_id',
    {
        data_type   => 'INT',
        size        => 11,
        is_nullable => 0
    },
    'description',
    {
        data_type   => 'VARCHAR',
        size        => 64,
        is_nullable => 0
    }
);

__PACKAGE__->set_primary_key('uuid');

1;
