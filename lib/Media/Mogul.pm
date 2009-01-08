package Media::Mogul;

use Moose;

our $VERSION = '0.01';

has 'processor' => (
    is  => 'rw',
    isa => 'Media::Mogul::Processor',
);

=head1 NAME

Media::Mogul - Monopolistic Media Management

=head1 VERSION

Version 0.01

=cut

sub BUILD {
    my ( $self ) = @_;
    # How to load processors?
}

sub process {
    my ( $self ) = @_;
    $self->processor->process( $self, @_ );
}

=head1 SYNOPSIS

Media::Mogul provides centralized management of media objects with a sane and
conventional interface, regardless of media type, with multiple store support.

The most commonly used store, in that it is the only store that we actively use,
is L<MogileFS>.

    use Media::Mogul;

    my $mm = Media::Mogule->new(
        store => {
            backend => 'MogileFS',
            config  => { trackers => [ '127.0.0.1:6001' ] }
        }
    );
    
    my $media = $mm->find($key); # Returns Media::Mogul::Object

    unless ( $media ) {
        die $mm->error if $mm->error;
        print "$key not found!\n";
    }


    $media->meta; # Returns Media::Mogul::Meta

    {
        # Scope is important, or make sure to call $fh->close;
        my $fh = $mm->store; # Media::Mogul::IO
        
    } # Once the scope is left, the meta parser kicks in.  This is just
      # a fancy call to $fh->close;
 

=cut

no Moose;

=head1 AUTHOR

J. Shirley, C<< <jshirley at coldhardcode.com> >>

A Cold Hard Code, LLC Production

=head1 BUGS

Please report any bugs or feature requests to C<bug-media-mogul at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Media-Mogul>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Media::Mogul


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Media-Mogul>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Media-Mogul>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Media-Mogul>

=item * Search CPAN

L<http://search.cpan.org/dist/Media-Mogul>

=back


=head1 ACKNOWLEDGEMENTS

The L<Moose> Crew

=head1 COPYRIGHT & LICENSE

Copyright 2008 Cold Hard Code, LLC.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Media::Mogul
