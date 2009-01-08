package MooseX::Storage::IO::MogileFS;

use Moose::Role;

use MooseX::Storage::Engine::IO::MogileFS;

our $VERSION = '0.01';

requires 'thaw';
requires 'freeze';


sub load {
    my ( $class, $client, $key, @args ) = @_;
    die "No MogileFS client instantiated" 
        unless $client and $client->isa('MogileFS::Client');
    $class->thaw( 
        MooseX::Storage::Engine::IO::MogileFS->new( 
            client => $client, key => $key 
        )->load,
        @args
    );
}

sub store {
    my ( $class, $mog_class, $key, @args ) = @_;
    my $client = $class->client;
    die "No MogileFS client instantiated" 
        unless $client and $client->isa('MogileFS::Client');
    MooseX::Storage::Engine::IO::MogileFS
        ->new( key => $key, client => $class->client )
        ->store( $mog_class, $class->freeze(@args) );
}

1;
