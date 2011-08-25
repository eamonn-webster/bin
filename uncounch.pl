#******************************************************************************
#
#  File: uncounch.pl
#  Author: eweb
#  Copyright WBT Systems, 2006
#  Contents: Un checkout unchanged files.
#
#******************************************************************************
#
# Date:          Author:  Comments:
# 27th Oct 2006  eweb     Use strict.
#

use strict;

my $ctool = "cleartool";

my $start  = $ARGV[0];
my $force  = $ARGV[1];

if ( $start eq "" )
  {
    $start = ".";
  }

my $cmd = "$ctool lsco -cview -avobs -short";

print "cmd: $cmd\n";

open( FILES, "$cmd 2>&1 |" ) or die;

while ( <FILES> )
  {
    chomp;
    my $file = $_;
    #print $file;

    # predecessor
    $cmd = "$ctool diff -pred \"$file\"";

    my $diffs = `$cmd`;
    #print "[$diffs]\n";
    if ( $diffs =~ /^Files are identical/ )
      {
        $cmd = "$ctool unco -rm \"$file\"";
        print "$cmd\n";
        my $userInput = "n";
        if ( $force eq "y" )
          {
            $userInput = "y";
          }
        else
          {
            #system( "clearvtree \"$element\"" );
            print "un checkout y/n?";
            $userInput = <STDIN>;
            chomp $userInput;
          }
        if ( $userInput eq "y" )
          {
            system( $cmd );
          }
      }
  }

close FILES;

