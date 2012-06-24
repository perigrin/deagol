package Deagol::Resource::Page;
use Moose;
use namespace::autoclean;
use GitStore;
extends qw(Web::Machine::Resource);

has store   => ( is => 'rw' );
has context => ( is => 'rw', );

sub init {
    shift->store( GitStore->new('/tmp/test-wiki') );
}

sub allowed_methods { [qw[ GET PUT]] }

sub resource_exists {
    my $self = shift;
    $self->context( $self->store->get( $self->request->path_info ) );
}

sub content_types_accepted { [ { '*/*'       => 'from_any' } ] }
sub content_types_provided { [ { '*/*' => 'to_any' } ] }

sub from_any {
    my $self = shift;
    $self->store->set( $self->request->path_info, $self->request->content );
    $self->store->commit();
}

sub to_any {
    my $self = shift;
    my $data = $self->context;
    return $data;
}

1;
__END__
