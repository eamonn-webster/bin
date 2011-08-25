#******************************************************************************
#
#  File: unbr.pl
#  Author: eweb
#  Copyright WBT Systems, 2006-2008
#  Contents: Remove a branch...
#
#******************************************************************************
#
# Date:          Author:  Comments:
# 27th Oct 2006  eweb     Use strict.
# 22nd Feb 2007  eweb     Not detecting sub branches correctly.
#

use strict;

#remove zero branches (without labels)

# FAILURE

#eweb_700_list_management
#cleartool find . -version "version(\main\eweb_700_list_management\0) && version(\main\eweb_700_list_management\LATEST)" -print
#.\oracle\topclass\Neo\Includes\oracle_api\CSqlObject.h
#cleartool lshistory -fmt "[%m-%o] %Xn\n" ".\oracle\topclass\Neo\Includes\oracle_api\CSqlObject.h@@\main\eweb_700_list_management\0"
#cleartool rmbranch -force ".\oracle\topclass\Neo\Includes\oracle_api\CSqlObject.h@@\main\eweb_700_list_management"




# input is a branch...

my $ctool = "cleartool";

#my $branch = "422_branch\\423_branch\\424_branch\\425_branch\\426_branch\\427_branch\\428_branch";
my $branch = $ARGV[0];
my $start = $ARGV[1];
my $rmbranch = $ARGV[2];

if ( $branch eq "" )
  {
    die "Usage: perl $0 branch start rmbranch\n";
  }

if ( $start eq "" )
  {
    $start = ".";
  }

my $cmd = "$ctool find $start -version \"version(\\main\\$branch\\0) && !version(\\main\\$branch\\LATEST)\" -print";

print "cmd: $cmd\n";

open( VERSIONS, "$cmd 2>&1 |" ) or die;

while ( <VERSIONS> )
  {
    #removeZeroBranch();
    unBranch();
  }
close VERSIONS;

sub unBranch()
  {
    chomp;
    my $version = $_;
    #print $version;

    $version =~ /(.*)@@(.*)/;
    my $element = $1;
    my $verspec = $2;

    print "$element\n";

    $cmd = "cleartool diff -serial \"$element\@\@\\main\\$branch\\LATEST\" \"$element\@\@\\main\\$branch\\0\"";
    system( $cmd );
    my $userInput = $rmbranch;
    while ( $userInput ne "y" and $userInput ne "n" )
      {
        if ( $userInput eq "t" )
          {
            system( "clearvtree \"$element\"" );
          }
        elsif ( $userInput eq "d" )
          {
            system( "cleartool diff -serial \"$element\@\@\\main\\$branch\\LATEST\" \"$element\@\@\\main\\$branch\\0\"" );
          }
        elsif ( $userInput eq "g" )
          {
            system( "cleartool diff -graphical \"$element\@\@\\main\\$branch\\LATEST\" \"$element\@\@\\main\\$branch\\0\"" );
          }
        print "Remove branch y/n?";
        $userInput = <STDIN>;
        chomp $userInput;
      }
    #$cmd = "$ctool rmbranch -force \"$element\@\@\\main\\$branch\"";
    #print "$cmd\n";
    #if ( $userInput eq "y" )
    #  {
    #    system( $cmd );
    #  }
  }

sub removeZeroBranch()
  {
    chomp;
    my $version = $_;
    #print $version;

    $version =~ /(.*)@@(.*)/;
    my $element = $1;
    my $verspec = $2;

    print "$element\n";

    $cmd = "$ctool desc -fmt \"%[type]p\" \"$version\"";
    #print "$cmd\n";
    my $directory;
    if ( `$cmd` eq "directory" )
      {
        $directory = "-directory";
      }
    # list labels
    #$cmd = "$ctool desc -alabel -all \"$version\"";
    $cmd = "$ctool desc -fmt \"%Nl\\n\" \"$version\"";
    #print "$cmd\n";
    my $hasLabels = 0;
    my $hasBranches = 0;
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
                $hasLabels = 1;
                last;
              }
          }
      }
    close LABELS;
    $cmd = "$ctool lshistory $directory -fmt \"[%m-%o] %Xn\\n\" \"$version\"";
    #print "$cmd\n";
    open( EVENTS, "$cmd 2>&1 |" ) or die;
    while ( <EVENTS> )
      {
        chomp;
        my $event = $_;
        my $qbranch = quotemeta( $branch );
        print "$event\n" if ( $event =~ /$qbranch/ );

        # $event = "[branch-mkbranch] \topclass\oracle\topclass\sources\wexer.cpp@@\main\eweb_720_work_9\stuff";
        # $event = "[version-mkbranch] .\Learning.tmpl@@\main\721_branch\esd_branch_acs_722\0
        # $event = "[branch-mkbranch] .\Learning.tmpl@@\main\721_branch\esd_branch_acs_722
        # $event = ".\Learning.tmpl   721_branch\esd_branch_acs_722

        if ( /\[(version|branch)-mkbranch\] (.*)\@\@\\main\\(.*)$/ )
          {
            my $element = $2;
            my $mkbranch = $3;
            print "$element   [$mkbranch]\n" if ( $event =~ /$qbranch/ );
            # was this branch, branched from $branch
            if ( $mkbranch =~ /$qbranch\\(.+)\\[0-9]+$/ )
              {
                print "has sub branch $1\n";
                $hasBranches = 1;
                last;
              }
          }
        if ( $directory ne "" && /\[directory version-mkbranch\] (.*)\@\@\\main\\(.*)/ )
          {
            my $element = $1;
            my $mkbranch = $2;
            print "$element   $mkbranch\n";
            # was this branch, branched from $branch
            if ( $mkbranch =~ /$qbranch\\(.+)\\[0-9]+$/ )
              {
                print "has sub branch $1\n";
                $hasBranches = 1;
                last;
              }
          }
      }
    close EVENTS;
    if ( $hasLabels == 0 && $hasBranches == 0 )
      {
        my $userInput;
        if ( $rmbranch eq "y" )
          {
            $userInput = "y";
          }
        elsif ( $rmbranch eq "n" )
          {
            $userInput = "n";
          }
        else
          {
            if ( $rmbranch eq "t" )
              {
                system( "clearvtree \"$element\"" );
              }
            print "Remove branch y/n?";
            $userInput = <STDIN>;
            chomp $userInput;
          }
        $cmd = "$ctool rmbranch -force \"$element\@\@\\main\\$branch\"";
        print "$cmd\n";
        if ( $userInput eq "y" )
          {
            system( $cmd );
          }
      }
  }
