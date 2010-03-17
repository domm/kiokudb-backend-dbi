package KiokuDB::TypeMap::Entry::DBIC::Row;
use Moose;

use JSON;
use Scalar::Util qw(weaken);

use namespace::autoclean;

with qw(KiokuDB::TypeMap::Entry);

has json => (
    isa => "Object",
    is  => "ro",
    default => sub { JSON->new },
);

sub compile {
    my ( $self, $class ) = @_;

    my $json = $self->json;

    return KiokuDB::TypeMap::Entry::Compiled->new(
        collapse_method => sub {
            my ( $collapser, @args ) = @_;

            $collapser->collapse_first_class(
                sub {
                    my ( $collapser, %args ) = @_;

                    my $obj = $args{object};

                    if ( my @objs = values %{ $obj->{_kiokudb_column} } ) {
                        $collapser->visit(@objs);
                    }

                    my $entry = $collapser->make_entry(
                        %args,
                        data => $obj,
                    );

                    return $entry;
                },
                @args,
            );
        },
        expand_method => sub {
            my ( $linker, $entry ) = @_;

            my $obj = $entry->data;

            $linker->register_object( $entry => $obj );

            return $obj;
        },
        id_method => sub {
            my ( $self, $object ) = @_;

            return 'row:' . $json->encode([ $object->result_source->source_name, $object->id ]);
        },
        refresh_method => sub {
            my ( $linker, $object, $entry, @args ) = @_;
            $object->discard_changes; # FIXME avoid loading '$entry' alltogether
        },
        entry => $self,
        class => $class,
    );
}

__PACKAGE__->meta->make_immutable;

# ex: set sw=4 et:

__PACKAGE__

__END__
