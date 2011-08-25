use strict;


my $testing = "N";

my $MsSqlHost = "prism";
my $desc      = "DSN for connecting to topclass";
my $schemaName = "tc742";

    my $ODBC     = "HKLM\\SOFTWARE\\ODBC\\odbc.ini";
    my $ODBCInst = "HKLM\\SOFTWARE\\ODBC\\odbcinst.ini";

    RegAdd( "$ODBC\\$MsSqlHost", "Description", $desc );


    my $SysRoot = RegGet( "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion", "SystemRoot" );

    my $ODBCDriver = "$SysRoot\\System32\\SQLSRV32.dll";

    RegAdd( "$ODBC\\$MsSqlHost", "Driver", $ODBCDriver );

    RegAdd( "$ODBC\\$MsSqlHost", "LastUser", $schemaName );

    RegAdd( "$ODBC\\$MsSqlHost", "Server", $MsSqlHost );

    RegAdd( "$ODBC\\ODBC Data Sources", $MsSqlHost, "SQL Server" );

    RegAdd( "$ODBCInst\\SQL Server", "CPTimeout", "<not pooled>" );



sub RegAdd( $$$ )
  {
    my ( $key, $name, $value ) = @_;

    my $cmd = "reg add \"$key\" /v \"$name\" /d \"$value\" /f";
    if ( $testing eq "Y" )
      {
        print "$cmd\n";
        return;
      }

    runCmd( $cmd, "The operation completed successfully" );
  }

sub RegGet( $$ )
  {
    my ( $key, $name ) = @_;

    my $cmd = "reg query \"$key\" /v \"$name\"";
    print "$cmd\n";

    my $gotIt = 0;
    if ( open( REG, "$cmd |" ) )
      {
        while ( <REG> )
          {
            if ( /\s+$name\s+REG_.+\s+(.+)/i )
              {
                if ( $testing eq "Y" )
                  {
                    print " => $1\n";
                  }
                return $1;
              }
          }
      }
    if ( $testing eq "Y" )
      {
        print " => undef\n";
      }
  }

sub runCmd( $% )
  {
    my ( $cmd, @filters ) = @_;

    print "$cmd\n";
    if ( $testing eq "Y" )
      {
        return;
      }
    if ( open( CMD, "$cmd |" ) )
      {
        while (<CMD>)
          {
            my $line = $_;
            if ( $line =~ /^$/ )
              {
              }
            else
              {
                my $matched = 0;
                foreach my $filter ( @filters )
                  {
                    if ( $line =~ /$filter/ )
                      {
                        $matched = 1;
                        last;
                      }
                  }
                if ( $matched eq 0 )
                  {
                    print "$_";
                  }
              }
          }
      }
  }

