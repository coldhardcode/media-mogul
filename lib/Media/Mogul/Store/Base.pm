package Media::Mogul::Store::Base;

use Moose;
use UUID::Random;

has 'id_generator' => (
    is  => 'rw',
    isa => 'CodeRef',
    optional => 1,
    default => sub { sub { UUID::Random::generate } }
);

sub store { }
sub fetch { }

1;
