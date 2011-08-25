#
#  File: mkcs.pl
#  Author: eweb
#  Contents: Generate the correct config spec.
#
# Date:          Author:  Comments:
#  2nd Feb 2007  eweb     Initial version.
#

# inputs

# what exactly are we trying to do?
# To rebuild an existing build (it was deleted)?
# - the label except for /utils/AutoDevBuild/...
# To build and debug possibly making changes?
# To do a patch
# To do a build
# To do a custom build (like a patch add customer to label)

use strict;
use Getopt::Std;

my %opts;

if ( !getopts( "v:", \%opts ) )
  {
    die "perl $0 -v mnp:bbb\n";
  }

my $mnpb = $opts{v};

if ( $mnpb eq "" )
  {
    die "perl $0 -v mnp:bbb\n";
  }

my $Major;
my $Minor;
my $Point;
my $Build;
if ( $mnpb =~/([1-9]+)([0-9]+)([0-9]+)(:([0-9]+))?/ )
  {
    $Major = $1;
    $Minor = $2;
    $Point = $3;
    $Build = $5;
  }

print "# $Major.$Minor.$Point.$Build\n";

my @Branches =
  ( ["314_branch"],
    ["421_branch", "", "TC_421_BUILD_022"],
    ["422_branch", "421_branch"],
    ["423_branch", "422_branch"],
    ["424_branch", "423_branch"],
    ["425_branch", "424_branch"],
    ["426_branch", "425_branch"],
    ["427_branch", "426_branch"],
    ["428_branch", "427_branch"],
    ["428_dow_branch", "", "TC_421_BUILD_022"],
    ["521_branch"],
    ["602_branch"],
    ["603_branch", "602_branch"],
    ["610_branch"],
    ["620_branch"],
    ["630_branch", "", "TC_621_BUILD_122"],
    ["630_volvo_branch", "630_branch", "TC_630_BUILD_184"],
    ["710_branch"],
    ["720_branch"],
    ["73x_branch"],
    ["740_branch"],
    ["741_branch"],
  );

my @Versions =
  ( ["3.0.0",     ""],
    ["3.1.0",     ""],
    ["3.1.1",     ""],
    ["3.1.2",     ""],
    ["3.1.3",     ""],
    ["3.1.4",     "314_branch"],
    ["4.0.0",     ""],
    ["4.1.0",     ""],
    ["4.2.0",     ""],
    ["4.2.1",     "421_branch"],
    ["4.2.2",     "422_branch"],
    ["4.2.3",     "423_branch"],
    ["4.2.4",     "424_branch"],
    ["4.2.5",     "425_branch"],
    ["4.2.6",     "426_branch"],
    ["4.2.7",     "427_branch"],
    ["4.2.8",     "428_branch"],
    ["4.2.8.254", "428_dow_branch"],
    ["5.0.0",     ""],
    ["5.1.0",     ""],
    ["5.2.0",     ""],
    ["5.2.1",     "521_branch"],
    ["6.0.0",     "521_branch"],
    ["6.0.2",     "602_branch"],
    ["6.0.3",     "603_branch"],
    ["6.1.0",     "610_branch"],
    ["6.2.0",     "620_branch"],
    ["6.3.0",     "630_branch"],
    ["6.3.0.210", "630_volvo_branch"],
    ["6.3.2",     "630_branch"],
    ["6.3.3",     "630_branch"],
    ["7.0.0",     ""],
    ["7.1.0",     "710_branch"],
    ["7.2.0",     "720_branch"],
    ["7.3.0",     ""],
    ["7.3.0.096", "73x_branch"],
    ["7.4.0",     ""],
    ["7.4.0.130", "740_branch"],
    ["7.4.1.140", "741_branch"],
    ["7.4.2",     ""],
  );
  
my @branches;

for ( my $i = 0; $i < $#Versions; $i++ )
  {
    my $v0 = $Versions[$i];
    my @v = @$v0;

    #print "@v\n";
    if ( $v[0] gt "$Major.$Minor.$Point.$Build" )
      {
        # got it...
        $v0 = $Versions[$i-1];
        @v = @$v0;
        print "# " . $v[0] . ": " . $v[1] .":\n";
        print "element * CHECKEDOUT\n";
        print "element /utils/AutoDevBuild/... /main/LATEST\n";

        my $b = $v[1];
        my @branches;
        while ( $b ne "" )
          {
            @branches = ($b, @branches);
            foreach (@Branches)
              {
                my @bb = @$_;
                if ( $bb[0] eq $b )
                  {
                    $b = $bb[1];
                    if ( $b ne "" )
                      {
                      }
                  }
              }
          }

        #@branches = ( 1, 2, 3, 4, 5, 6 );
        #print "all:@branches\n";
        #print "most:@branches[0 .. -1]\n";

        print "element \* /main";
        foreach ( @branches )
          {
            print "/$_";
          }
        print "/LATEST\n";
        #print "\n";

        while ( $#branches >= 0 )
          {
            # remove the last...
            my $lbranch = $branches[$#branches];
            if ( $lbranch eq "" )
              {
                last;
              }
            @branches = @branches[0 .. $#branches-1];

            my $blabel;
            foreach (@Branches)
              {
                my @bb = @$_;
                if ( $bb[0] eq $lbranch )
                  {
                    $blabel = $bb[2];
                    last;
                  }
              }
            if ( $blabel ne "" )
              {
                print "element \* /main";
                foreach ( @branches )
                  {
                    print "/$_";
                  }
                print "/$blabel -mkbranch $lbranch\n";
                #print "\n";
              }
            print "element \* /main";
            foreach ( @branches )
              {
                if ( $_ ne "" )
                  {
                    print "/$_";
                  }
              }
            print "/LATEST -mkbranch $lbranch\n";
          }
        print "\n";

        #print "element * /main/630_branch/TC_630_BUILD_184 -mkbranch 630_volvo_branch\n";
        #print "element * /main/630_branch/LATEST -mkbranch 630_volvo_branch\n";

        #print "element * /main/630_branch/LATEST\n";
        #print "element * /main/TC_621_BUILD_122 -mkbranch 630_branch\n";
        #print "element * /main/LATEST -mkbranch 630_branch\n";
        last;
      }
  }
  
  