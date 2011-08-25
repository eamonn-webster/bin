#******************************************************************************
#
#  File: devbuild.pl
#  Author: Patrick Maher - pmaher@wbtsystems.com
#  Copyright WBT Systems, 2005-2007
#  Contents: Build Automation
#
#******************************************************************************
#
# Date:          Author:  Comments:
#

use strict;

use DBI;

  my $MajorReleaseNo        = "";                            # TopClass Major Release Number
  my $MinorReleaseNo        = "";                            # TopClass Minor Release Number (if not applicable set to "")
  my $PointReleaseNo        = "";
  my $CurrentBuildNoStr     = "";
  my $Branch                = "main";

  use Getopt::Std;

  my %opts = ( b => undef(),
               m => undef(),
               n => undef(),
               p => undef(),
               B => undef(),
               );

  my $Sec                   = 0;
  my $Min                   = 0;
  my $Hour                  = 0;
  my $Day                   = 0;
  my $Month                 = 0;
  my $Year                  = 0;
  ($Sec, $Min, $Hour, $Day, $Month, $Year ) = localtime(time);
  $Year  = $Year + 1900;
  $Month = $Month + 1;

  if ( $Month < 10 )
    {
      $Month = "0$Month";
    }
  if ( $Day < 10 )
    {
      $Day = "0$Day";
    }
  if ( $Hour < 10 )
    {
      $Hour = "0$Hour";
    }
  if ( $Min < 10 )
    {
      $Min = "0$Min";
    }

  if ( !getopts("b:m:n:p:B:", \%opts) or @ARGV > 0 )
    {
      print STDERR "Unknown arg $ARGV[0]\n\n" if @ARGV > 0;
      #Usage();
      exit;
    }
  #for my $o ( keys %opts ) 
  #  {
  #    print $o . "=" . $opts{$o} . "\n";
  #  }
  if ( !defined( $opts{m}) || !defined( $opts{n}) || !defined( $opts{p}) || !defined( $opts{b} ) )
    {
      print "You MUST supply a major<-m>, minor <-n> and point <-p> and build <-b> number to this script!\n\n";
      #Usage();
      exit;
    }
  if ( defined( $opts{b} ) )
    {
      $CurrentBuildNoStr = $opts{b};
    }
  if ( defined( $opts{m} ) )
    {
      $MajorReleaseNo = $opts{m};
    }

  if ( defined( $opts{n} ) )
    {
      $MinorReleaseNo = $opts{n};
    }

  if ( defined( $opts{p} ) )
    {
      $PointReleaseNo = $opts{p};
    }

  if ( defined( $opts{B} ) )
    {
      $Branch = $opts{B};
    }

sub UpdateBuildSchedule()
  {
    #my $status = 1;
    #StartDiv( "UpdateBuildSchedule", "UpdateBuildSchedule" );

    print "UpdateBuildSchedule\n";
    #print BUILDLOG "UpdateBuildSchedule\n";

    my $database = "builds";
    my $hostname = "granite.dublin.wbtsystems.com";
    my $port = "";
    my $username = "nickm";
    my $password = "BobTheBuilder";
    my $dsn = "DBI:mysql:database=$database;host=$hostname;port=$port";
    my $dbh = DBI->connect($dsn, $username, $password);

    my  $sql = "INSERT INTO releases( version, deliverydate, name, customer, clearcase, description, release )\n"
             . "VALUES\n"
             . "( '${MajorReleaseNo}.${MinorReleaseNo}.${PointReleaseNo}.${CurrentBuildNoStr}', '${Year}-${Month}-${Day} ${Hour}:${Min}:${Sec}', '', '', '$Branch', '', 0 );";

    print "$sql\n";
    #print BUILDLOG "$sql\n";
    my $sth = $dbh->prepare( $sql );

    $sth->execute;

    #EndDiv( "UpdateBuildSchedule", $status );
  }

UpdateBuildSchedule();
