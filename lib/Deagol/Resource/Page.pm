package Deagol::Resource::Page;
use Moose;
use namespace::autoclean;
use GitStore;
extends qw(Web::Machine::Resource);

has store   => ( is => 'rw' );
has context => ( is => 'rw', );

sub init { shift->store( GitStore->new('.') ) }

sub resource_exists {
    my $self = shift;
    $self->context( $self->store->get( $self->request->path_info ) );
}

sub content_types_provided { [ { 'text/html' => 'to_html' } ] }

sub to_html {
    my $self = shift;
    my $data = $self->context;
    return <<"END_HTML"
<html>
    <head>
        <title>Deagol!</title>
    </head>
    <body>
        <pre>$data</pre>
    </body>
</html>

END_HTML

}

1;
__END__
