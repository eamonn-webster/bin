#
# dumpschema.pl
#

use strict;
use DBD::ODBC;
  use Getopt::Std;

my %opts;

getopts( "d:u:p:h:", \%opts );

my $dbdsn = $opts{h};
my $dbusername = $opts{u};;
my $dbpass = $opts{p};;
my $driver = $opts{d};;

    if ( $dbdsn eq "" ) {
        $dbdsn  = "quark_10";
    }
    if ( $dbusername eq "" ) {
        $dbusername = "tc800";
    }
    if ( $dbpass eq "" ) {
        $dbpass = "tc800";
    }
    if ( $driver eq "" ) {
        $driver = "ODBC";
    }

    my $connectstr = "'dbi:$driver:$dbdsn','$dbusername','$dbpass'";

    print "Connection String: $connectstr\n";


    my $dbh = DBI->connect("dbi:$driver:$dbdsn",$dbusername,$dbpass)  || die "can't connect to database $dbdsn,$dbusername,$dbpass";

    $dbh->{LongReadLen} = 64000;

    my $query = "SELECT object_type, object_name FROM user_objects WHERE object_name = 'S_WQUESTION_AFTER'";

    my ($sth1) = $dbh->prepare($query) or die "prepare: " . $dbh->errstr();

    if ( !$sth1->execute() ) {
        #logERROR( "findGroupTree: execute: $query" );
        print $dbh->errstr();
    }
    else {
        while (my ($type, $name) = $sth1->fetchrow_array) {
            if ( $name =~ /^SYS_/ ) {
            }
            elsif ( $type eq "TABLE" or $type eq "VIEW" ) {
                print "[$type, $name]\n";
                $query = "select dbms_metadata.get_ddl( '$type', UPPER('$name') ) from dual;";

                my ($sth2) = $dbh->prepare($query) or die "prepare: " . $dbh->errstr();
                if ( !$sth2->execute() ) {
                    logERROR( "findGroupTree: execute: $query" );
                    logERROR( $dbh->errstr() );
                }
                else {
                    my $dir = lc $type . 's';
                    mkdir( $dir );

                    my $path = $dir . '\\' . lc $name . '.sql';

                    print "path: $path\n";
                    if ( open( SQLOUT, ">$path" ) ) {
                        while (my $line = $sth2->fetchrow_array) {
                            $line =~ s/STORAGE\([^)]+\)//gm;
                            $line =~ s/PCTFREE\s+[0-9]+\s+INITRANS\s+[0-9]+\s+MAXTRANS\s+[0-9]+\s+COMPUTE\s+STATISTICS//gm;
                            $line =~ s/PCTFREE\s+[0-9]+\s+PCTUSED\s+[0-9]+\s+INITRANS\s+[0-9]+\s+MAXTRANS\s+[0-9]+\s+NOCOMPRESS\s+LOGGING//gm;
                            $line =~ s/ENABLE\s+STORAGE\s+IN\s+ROW\s+CHUNK\s+[0-9]+\s+PCTVERSION\s+[0-9]+\s+NOCACHE\s+LOGGING//gm;
                            print "$line\n";
                            print SQLOUT "$line\n";
                        }
                        close( SQLOUT );
                    }
                }
               $sth2->finish();
            }
        }
    }

    $sth1->finish();

