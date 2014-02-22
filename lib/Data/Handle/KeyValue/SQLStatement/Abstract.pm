package Data::Handle::KeyValue::SQLStatement::Abstract;

use Moose;
use MooseX::Params::Validate;
use SQL::Abstract;

extends 'Data::Handle::KeyValue::SQLStatement';

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;

    my %params = @_;

    my $dbh = $params{dbh};
    delete $params{dbh};

    my ( $table, $columns, $where, $order ) = validated_list(
        [%params],
        table   => { isa => 'Str' },
        columns => { isa => 'ArrayRef' },
        where   => { isa => 'HashRef', optional => 1 },
        order   => { isa => 'HashRef', optional => 1 },
    );

    my ( $stmt, @bind )
        = SQL::Abstract->new()->select( $table, $columns, $where, $order )
        or die
        "Could not create select statement for Data::Handle::KeyValue::SQLStatement::Abstract via SQL::Abstract: $!";

    return $class->$orig(
        dbh           => $dbh,
        sql_statement => $stmt,
        bind_values   => \@bind
    );
};

__PACKAGE__->meta()->make_immutable();

1;
