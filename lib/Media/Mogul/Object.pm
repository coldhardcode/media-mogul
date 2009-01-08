package Media::Mogul::Object;

use Moose;

use MooseX::Types::UUID qw(UUID);
use MIME::Types;

has 'metadata' => (
    is  => 'rw',
    isa => 'HashRef',
    default => sub { {} }
);

has 'data' => (
    is  => 'rw',
    isa => 'Item',
);

has 'original' => (
    is  => 'rw',
    isa => 'Item',
);

has 'mime' => (
    is  => 'rw',
    isa => 'MIME::Type',
    default => sub { MIME::Types->new->type('text/plain'); }
);

has 'uuid' => (
    is  => 'rw',
    isa => 'Str',
    where => sub { $_ =~ /^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/ }
);

=head2 mime 

A C<MIME::Type> accessor

Defaults to "text/plain"

=cut

1;

