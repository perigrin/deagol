package Deagol;
use Moose;

# ABSTRACT: An amazing new application!

use Web::Machine;
use Deagol::Resource::Page;

sub app { Web::Machine->new( resource => 'Deagol::Resource::Page' )->to_app; }

1;
__END__
