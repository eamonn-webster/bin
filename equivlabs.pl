#******************************************************************************
#
#  File: equivlabs.pl
#  Author: eweb
#  Copyright WBT Systems, 2007
#  Contents: Check labels fro equivalance
#
#******************************************************************************
#
# Date:          Author:  Comments:
# 16th Jan 2007  eweb     Created.
#

use strict;

my $lab1 = $ARGV[0];
my $lab2 = $ARGV[1];
my $start = $ARGV[2];
my $both = $ARGV[3];

if ( $lab1 eq "" or $lab2 eq "" )
  {
    die "Must specify two labels\n";
  }

if ( $start eq "" )
  {
    $start = ".";
  }

my $cmd = "cleartool find $start -version lbtype($lab1) -print";

#mikelib@@\main\1
#mikelib\reader.cpp@@\main\14
#mikelib\readwrit.cpp@@\main\4
#mikelib\readwrit.h@@\main\2
#mikelib\reshead.cpp@@\main\9
#mikelib\reshead.h@@\main\3

print "$cmd\n";

if ( open( LAB1, "$cmd 2>&1 |" ) )
  {
    while ( <LAB1> )
      {
        chomp;
        my $item = $_;
        #my $descCmd = "cleartool desc -fmt \"\" $item";
        #my ( $element, $version ) = split( /\@\@/ );
        $cmd = "cleartool desc -fmt \"%Nl\\n\" \"$item\"";
        #print "$cmd\n";
        my $hasBoth = 0;
        if ( open( LABELS, "$cmd 2>&1 |" ) )
          {
            while ( <LABELS> )
              {
                chomp;
                my $labelLine = $_;
                #print $labelLine;

                if ( split( / /, $labelLine ) )
                  {
                    foreach my $label ( split( / /, $labelLine ) )
                      {
                        if ( $label eq $lab2 )
                          {
                            #print "$label\n";
                            $hasBoth = 1;
                            last;
                          }
                      }
                  }
              }
            close LABELS;
          }
        if ( $hasBoth eq 0 )
          {
            print "$item has $lab1 but not $lab2\n";
          }
      }
    close( LAB1 );
  }

if ( lc $both eq "y" )
  {
    my $cmd = "cleartool find $start -version lbtype($lab2) -print";

    print "$cmd\n";

    if ( open( LAB2, "$cmd 2>&1 |" ) )
      {
        while ( <LAB2> )
          {
            chomp;
            my $item = $_;
            #my $descCmd = "cleartool desc -fmt \"\" $item";
            #my ( $element, $version ) = split( /\@\@/ );
            $cmd = "cleartool desc -fmt \"%Nl\\n\" \"$item\"";
            #print "$cmd\n";
            my $hasBoth = 0;
            if ( open( LABELS, "$cmd 2>&1 |" ) )
              {
                while ( <LABELS> )
                  {
                    chomp;
                    my $labelLine = $_;
                    #print $labelLine;

                    if ( split( / /, $labelLine ) )
                      {
                        foreach my $label ( split( / /, $labelLine ) )
                          {
                            if ( $label eq $lab1 )
                              {
                                #print "$label\n";
                                $hasBoth = 1;
                                last;
                              }
                          }
                      }
                  }
                close LABELS;
              }
            if ( $hasBoth eq 0 )
              {
                print "$item has $lab2 but not $lab1\n";
              }
          }
        close( LAB2 );
      }
  }

