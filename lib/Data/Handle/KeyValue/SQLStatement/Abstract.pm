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

=pod

=head1 SYNOPSIS

  use Data::Handle::KeyValue::SQLStatement::Abstract;
  use DBD::SQLite;
  use DBI;

  my $database = 't/test-data/travel-log.db';
  my $dbh
      = DBI->connect( "dbi:SQLite:dbname=$database", q{}, q{},
      { RaiseError => 1 },
      ) or die "Could not connect to $database: $DBI::errstr";

  my $table   = 'travel_log';
  my $columns = [ 'distance', 'date', ];
  my $where   = { distance => { '<' => 50 }, };
  my $order   = { -asc => 'distance', };

  my $data_handle = Data::Handle::KeyValue::SQLStatement::Abstract->new(
      dbh     => $dbh,
      table   => $table,
      columns => $columns,
      where   => $where,
      order   => $order,
  );

  while ( my $row = $data_handle->next_row() ) {
      ...;
  }

=head1 DESCRIPTION

Generally, the subclasses under L<Data::Handle::KeyValue> provide a consistent interface to retrieve rows of hash refs.

Specifically, this module, DHKV::SQLStatement::Abstract extends Data::Handle::KeyValue::SQLStatement, allowing you to break your SQL statement into logical parts rather than pass it as a whole string and bind values.

=head1 CONSTRUCTOR

=head2 C<new>

Takes three required parameters: C<dbh>, C<table> and C<columns>.

=over 4

=item * C<dbh> must be a DBI Database Handle of the class DBD::db.

=item * C<table> must be a string and refers to the table in your database you would like to query.

=item * C<columns> must be an array ref of the columns you would like data for.

=back

Also takes two optional parameters: C<where> and C<order>. Each must be a hash ref.

At construction your SQL statement is created, prepared and executed. A live data handle is returned.

For more details on C<table>, C<columns>, C<where> and C<order> see L<SQL::Abtract> as well as the CAVEAT below.

=head1 METHODS

=head2 C<next_row>

Retrieves the next row from your data handle as a hash ref.

=head1 CAVEAT

This module uses SQL::Abstract to compile your SQL statement. Even though SQLA can take other variable types for its parameters, this module limits them. If you need the full functionality of SQLA, you can use it first and then pass your statement and bind values to DHKV::SQLStatement.

=head1 SEE ALSO

L<Data::Handle::KeyValue>
L<Data::Handle::KeyValue::SQLStatement>
L<DBI>
L<SQL::Abstract>

=cut
