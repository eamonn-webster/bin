#******************************************************************************/
#
#  File: decompile-langs.pl
#  Author: eweb
#  Copyright WBT Systems, 2003-2007
#  Contents:
#
#******************************************************************************/
#
#  Date:          Author:  Comments:
#   4th May 2007  eweb     #????? Added lang and string set filters.
#

use strict;
use Getopt::Std;

# for each .dat file in a source languages directory
# decompile the corresponding .lang file in the binary directory


my %opts = ( l => undef(),
             s => undef(),
           );

# Was anything other than the defined option entered on the command line?
if ( !getopts("s:l:", \%opts) )
  {
    print STDERR "Unknown arg $ARGV[0]\n\n" if @ARGV > 0;
    die "Usage: perl $0 [-l lang] [-s stringset] binDir srcDir\n";
  }

my $binDir = $ARGV[0];
my $srcDir = $ARGV[1];

my $lang = $opts{l};
my $sset = $opts{s};

if ( $binDir eq "" || $srcDir eq "" )
  {
    die "Usage: perl $0 binDir srcDir\n";
  }

  if ( opendir( DIR, $srcDir ) )
    {
      my $file;
      my $Cmd;
      my $CmdOut;
      while ( defined( $file = readdir(DIR) ) )
        {
          #print "$file\n";
          if ( $file =~ /langrps\.dat$/ )
            {
            }
          elsif ( $file =~ /(.*)_(..)\.dat$/ )
            {
              #print "$file\n";
              if ( ( $sset eq "" || $sset eq $1 )
                   &&
                   ( $lang eq "" || $lang eq $2 ) )
                {
                  #print "$file\n";
                  # Generate .lang file
                  processLangFile( $file );
                }
            }
          elsif ( $file =~ /_abc\.dat$/ )
            {
            }
          elsif ( $file =~ /(.*)\.dat$/ )
            {
              if ( ( $sset eq "" || $sset eq $1 )
                   &&
                   ( $lang eq "" || $lang eq "us" ) )
                {
                  processLangFile( $file );
                }
            }
        }
      closedir(DIR);
    }


sub processLangFile( $ )
  {
    my ($datFile) = @_;
    print "$datFile\n";
    my $langFile;
    my $labelsFile;
    if ( open( DAT, "$srcDir\\$datFile" ) )
      {
        while ( <DAT> )
          {
            if ( /;Filename=(.*)_([^_]+)\.lang/ )
              {
                $langFile = "$1_$2.lang";
                $labelsFile = "$1.labels";
                last;
              }
          }
        close( DAT );
      }
    if ( -e "$binDir\\$langFile" && -e "$binDir\\$labelsFile" )
      {
        my $cmd = "langutils $binDir\\$langFile -L$binDir\\$labelsFile $datFile";
        my $cmdOut = `$cmd 2>&1`;
        print "$cmd\n";
        print "$cmdOut\n";
      }
    else
      {
        print "Files don't exist $binDir\\$langFile $binDir\\$labelsFile\n";
      }
  }

