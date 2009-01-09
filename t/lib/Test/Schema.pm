package # Hide from PAUSE
    Test::Schema;

use parent 'DBIx::Class::Schema';

use warnings;
use strict;

use Carp;
use DBI;

sub connect_info {
    [ 
        'dbi:SQLite:t/var/test.db',
        '', '',
        { quote_char => '`', name_sep => '.' }
    ]
}

sub init_schema {
    my ( $class, $params ) = @_;

    my @parts = DBI->parse_dsn( $class->connect_info->[0] );
    if ( $parts[1] =~ /sqlite/i ) {
        if ( -f $parts[4] ) {
            unlink($parts[4])
                or croak "Couldn't unlink $parts[4], deploy may fail";
        }
    }

    $class->load_classes;

    my $schema = $class->connect(@{ $class->connect_info });

    $schema->deploy;

    return $schema;
}

1;
