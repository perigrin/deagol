#!/usr/bin/env perl
use strict;
use Web::Machine;

# assuming you have lib::xi installed
# > plackup -Mlib::xi deagol.psgi

{

    package Deagol::Page;
    use Moose;
    use namespace::autoclean;

    use MooseX::NonMoose;
    extends qw(Web::Machine::Resource);

    use GitStore;
    use Time::Piece;
    use Text::MultiMarkdown qw(markdown);
    use Web::Machine::Util qw( create_date );

    has store => (
        isa     => 'GitStore',
        is      => 'ro',
        default => sub { GitStore->new('/tmp/test-wiki') }
    );

    has page => ( is => 'rw' );

    sub allowed_methods { [qw[ GET HEAD PUT DELETE ]] }

    sub resource_exists {
        my $self = shift;
        $self->page( $self->store->get( $self->request->path_info ) );
    }

    sub delete_resource {
        my $self = shift;
        $self->store->delete( $self->request->path_info );
        $self->store->commit( 'removed at' . Time::Piece->new() );
    }

    sub content_types_accepted { [ { 'text/markdown' => 'from_markdown' } ] }
    sub content_types_provided { [ { 'text/html'     => 'to_html' } ] }

    sub from_markdown {
        my $self = shift;
        $self->store->set( $self->request->path_info,
            $self->request->content );
        $self->store->commit( 'update at ' . Time::Piece->new() );
    }

    sub to_html {
        my $self = shift;
        markdown(
            $self->page,
            {   use_metadata    => 1,
                strip_metadata  => 1,
                document_format => 'complete'
            }
        );
    }
}

Web::Machine->new( resource => 'Deagol::Page', )->to_app;
