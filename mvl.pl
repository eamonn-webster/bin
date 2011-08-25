#******************************************************************************
#
#  File: mvl.pl
#  Author: eweb
#  Copyright WBT Systems, 2006
#  Contents: Move labels from 0 version to predecessor
#
#******************************************************************************
#
# Date:          Author:  Comments:
# 27th Oct 2006  eweb     Use strict.
#

use strict;

#look for 0 versions with labels...

# input is a branch...

my $ctool = "cleartool";

#$branch = "422_branch\\423_branch\\424_branch\\425_branch\\426_branch\\427_branch\\428_branch";
#$branch = "630_branch";
#$branch = "710_branch";
my $branch = $ARGV[0];
my $start  = $ARGV[1];
my $force  = $ARGV[2];
my $verbose = $ARGV[3];

if ( $branch eq "" )
  {
    die "Usage: perl $0 branch start force\n";
  }

if ( $start eq "" )
  {
    $start = ".";
  }

#my $cmd = "$ctool find $start -version \"version(\\main\\$branch\\0) && version(\\main\\$branch\\LATEST)\" -print";
my $cmd = "$ctool find $start -version \"version(\\main\\$branch\\0)\" -print";

print "cmd: $cmd\n";

open( VERSIONS, "$cmd 2>&1 |" ) or die;

while ( <VERSIONS> )
  {
    my $version = $_;
    #print $version;

    $version =~ /(.*)@@(.*)/;
    my $element = $1;
    my $verspec = $2;

    print "$element\n" if ( $verbose );
    # predecessor
    $cmd = "$ctool desc -pred \"$version\"";

    #print "$cmd\n";

    my $pred;
    open( PRED, "$cmd 2>&1 |" ) or die;
    while ( <PRED> )
      {
        if ( /predecessor version: (.*)/ )
          {
            $pred = $1;
            #print "[$pred]\n";
          }
      }
    close PRED;
    # list labels
    #$cmd = "$ctool desc -alabel -all \"$version\"";
    $cmd = "$ctool desc -fmt \"%Nl\\n\" \"$version\"";
    #print "$cmd\n";
    open( LABELS, "$cmd 2>&1 |" ) or die;
    while ( <LABELS> )
      {
        chomp;
        my $labelLine = $_;
        #print $labelLine;

        if (split(/ /, $labelLine))
          {
            foreach my $label (split(/ /, $labelLine))
              {
                print "$label\n";
                #print "$ctool mklabel -replace $label \"$element\@\@$pred\"\n";
              }
            my $userInput = "n";
            if ( $force eq "y" )
              {
                $userInput = "y";
              }
            else
              {
                system( "clearvtree \"$element\"" );
                print "move labels y/n?";
                $userInput = <STDIN>;
                chomp $userInput;
              }
            if ( $userInput eq "y" )
              {
                foreach my $label (split(/ /, $labelLine))
                  {
                    #print "$label\n";
                    $cmd = "$ctool mklabel -replace $label \"$element\@\@$pred\"";
                    system( $cmd );
                    #print "$cmd\n";
                  }
              }
          }
        #move label to predecessor
        #...
      }
    close LABELS;
    #system( "clearvtree \"$element\"" );
  }
close VERSIONS;

