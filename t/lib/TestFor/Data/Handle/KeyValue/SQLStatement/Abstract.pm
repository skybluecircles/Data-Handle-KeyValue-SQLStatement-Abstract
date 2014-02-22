package TestFor::Data::Handle::KeyValue::SQLStatement::Abstract;

use Data::Handle::KeyValue::SQLStatement::Abstract;
use DBD::SQLite;
use DBI;

use Test::Class::Moose;

sub test_abstract_sql_statement {
    my $self = shift;

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

    my @expected_rows = (
        { distance => 9,  date => '2013-07-13' },
        { distance => 12, date => '2013-07-12' },
        { distance => 14, date => '2013-07-11' },
        { distance => 15, date => '2013-07-06' },
        { distance => 17, date => '2013-07-07' },
        { distance => 19, date => '2013-07-08' },
        { distance => 20, date => '2013-07-05' },
        { distance => 32, date => '2013-07-09' },
    );

    foreach my $expected_row ( @expected_rows ) {
        my $row = $data_handle->next_row();
        is_deeply( $row, $expected_row,
            'Got expected row from abstract sql statement' );
    }
}

1;
