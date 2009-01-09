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

sub merge {
    my ( $self, $my_object, $object ) = @_;
    my $metadata = $self->merge_hashes( 
        $my_object->metadata, $object->metadata 
    );
    $my_object->metadata( $metadata );
    # Keep $self->data if we have it
    $my_object->data( $object->data ) unless $my_object->data;
    return $my_object;
}

# Taken from Catalyst::Utils
sub merge_hashes {
    my ( $self, $lefthash, $righthash ) = @_;

    return $lefthash unless defined $righthash;

    my %merged = %$lefthash;
    for my $key ( keys %$righthash ) {
        my $right_ref = ( ref $righthash->{ $key } || '' ) eq 'HASH';
        my $left_ref  = ( ( exists $lefthash->{ $key } && ref $lefthash->{ $key } ) || '' ) eq 'HASH';
        if( $right_ref and $left_ref ) {
            $merged{ $key } = merge_hashes(
                $lefthash->{ $key }, $righthash->{ $key }
            );
        }
        else {
            $merged{ $key } = $righthash->{ $key };
        }
    }

    return \%merged;
}

1;
