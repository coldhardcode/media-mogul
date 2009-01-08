package Media::Mogul::Processor;

use Moose;

has 'instance' => (
    is => 'rw',
    isa => 'Media::Mogul'
);

has 'pipeline' => (
    is  => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
);

sub process {
    my ( $self, $mm, $data, $type ) = @_;

    $self->instance($mm);
    my $obj = Media::Mogul::Object->new; 
    unless ( $type ) {
        return $self->identify_and_process( $obj, $data );
    }
   
    foreach my $proc ( @{ $self->pipeline } ) {
        $proc->process( $obj, $data ) if $proc->handles_type( $type );
    }
}

sub identify_and_process {
    my ( $self, $obj, $data ) = @_;
    my @types = ();
    foreach my $proc ( @{ $self->pipeline } ) {
        $proc->identify_and_process( $obj, $data );
    }
    # Merge to $type => $count, then sort?
    return @types;
}


1;
