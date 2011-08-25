#
#  File: clearcase_cleanup.pl
#  Author: eweb
#  Copyright eweb, 1998-2007
#  Contents:
#
#  Date:          Author:  Comments:
#  30th Aug 2007  eweb     #???? Drive mappings & restore script.

use strict;

use Getopt::Std;

my $cleartool1 = "cleartool"; # looks stuff up
my $cleartool2 = "cleartool"; # does okay stuff
my $cleartool3 = "cleartool"; # does dangerous stuff

$cleartool2 = "echo cleartool"; # does okay stuff
$cleartool3 = "echo cleartool"; # does dangerous stuff

my %opts = ( r => undef(),
             h => undef(),
             );

# Was anything other than the defined option entered on the command line?
if ( !getopts("rh:", \%opts) or @ARGV > 1 )
  {
    print STDERR "Unknown arg $ARGV[0]\n" if @ARGV > 0;
    #Usage();
    exit;
  }

my $Remove = "N";

if ( defined( $opts{r} ) )
  {
    $Remove = "Y";
  }

my $theHost = lc $ENV{COMPUTERNAME};

if ( defined( $opts{h} ) )
  {
    $theHost = $opts{h};
  }

my $cmd;

$cmd = "$cleartool1 lsview -host $theHost";

my @viewsOnThisHost;

if ( open( VIEWS, "$cmd |" ) )
  {
    while ( <VIEWS> )
      {
        if ( /[ *] ([^ ]*) +\\\\([^ \\]+)\\(.*)/ )
          {
            my $view = $1;
            my $host = $2;
            my $path = $3;
            if ( lc $host eq $theHost )
              {
                #print "$view \\\\$host\\$path\n";
                @viewsOnThisHost = ( @viewsOnThisHost, $view );
              }
          }
      }
    close( VIEWS );
  }

#print "@viewsOnThisHost\n";

if ( ! -d "c:/configspecs" )
  {
    mkdir( "c:/configspecs" );
  }

my %drives;

$cmd = "net use";
if ( open( DRIVES, "$cmd |" ) )
  {
    while ( <DRIVES> )
      {
        if ( /ClearCase Dynamic Views/ )
          {
            s/\s+ClearCase Dynamic Views//;
            #print;
            if ( /([^\s]*)\s*(.:)\s+\\\\view\\(.+)/ )
              {
                my $status = $1;
                my $drive = $2;
                my $view = $3;
                $drives{$view} = $drive;
                #print "[$status] $drive $view\n";
                #print "[$view] [$drives{$view}]\n";
              }
          }
      }
    close( DRIVES );
  }

if ( open( RESTORE, ">c:\\configspecs\\$theHost-restore.bat" ) )
  {
    foreach my $view ( @viewsOnThisHost )
      {
        #print "$view " . $drives{$view} . "\n";
        $cmd = "$cleartool1 catcs -tag $view > c:\\configspecs\\$view.txt";
        #print "$cmd\n";
        system( $cmd );
        if ( $Remove eq "Y" )
          {
            $cmd = "$cleartool3 rmview -tag $view";
            print "$cmd\n";
            system( $cmd );
            $cmd = "$cleartool3 rmtag -view -all $view";
            print "$cmd\n";
            system( $cmd );

          }
        print "$view $drives{$view}\n";
        print RESTORE "perl mkview.pl $view $drives{$view} n\n";
        print RESTORE "cleartool setcs $view c:\\configspecs\\$view.txt\n";
      }

    close( RESTORE );

    if ( $Remove eq "Y" )
      {
        $cmd = "$cleartool3 rmstgloc ${theHost}_ccstg_views";
        print "$cmd\n";
        system( $cmd );

        $cmd = "$cleartool3 rmstgloc ${theHost}_ccstg_vobs";
        print "$cmd\n";
        system( $cmd );
      }
  }


#z:
#cleartool lsco -cview -avobs
#cleartool lspriv

