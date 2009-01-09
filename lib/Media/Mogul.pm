package Media::Mogul;

use Moose;

use Media::Mogul::Object;

our $VERSION = '0.01';

has 'stores' => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub { [] }
);

has 'processors' => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub { [] }
);

=head1 NAME

Media::Mogul - Monopolistic Media Management

=head1 VERSION

Version 0.01

=cut

sub BUILD {
    my ( $self ) = @_;

    # How to load processors?
    my @stores = @{ $self->stores };

    my @configured_stores = ();
    while ( @stores ) {
        my ( $name, $config ) = (shift @stores, shift @stores);
        die "$name config is not a hash reference"
            unless $config and ref $config eq 'HASH';
        my $class = "Media::Mogul::Store::$name";
        if ( $name =~ /^\+/ ) {
            $class = $name;
        }
        Class::MOP::load_class($class)
            unless Class::MOP::is_class_loaded($class);

        my $s = $class->new( $config );
        push @configured_stores, $s;
    }
    $self->stores( \@configured_stores );

    return $self;
}

sub store {
    my ( $self, %params ) = @_;
    my $obj = Media::Mogul::Object->new( %params );
    foreach my $store ( @{ $self->stores } ) {
         $store->store( $obj );
    }
    return $obj->uuid;
}

sub fetch {
    my ( $self, $uuid ) = @_;

    my $obj;

    foreach my $store ( @{ $self->stores } ) {
        my $step_obj = $store->fetch( $uuid );
        if ( $step_obj and $obj ) {
            $obj = $store->merge( $step_obj, $obj );
        } elsif ( $step_obj ) {
            $obj = $step_obj;
        }
    }

    return $obj;
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
