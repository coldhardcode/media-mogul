package Media::Mogul::Processor::Image;

extends 'Media::Mogul::Processor';

has 'types' => (
    is  => 'rw',
    isa => 'ArrayRef',
    default => sub { [ qw/png jpg gif bmp tiff jpeg/ ] }
);

sub process {

}

sub identify_and_process {

}

1;
