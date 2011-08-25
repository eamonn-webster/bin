#******************************************************************************
#
#  File: rmunch.pl
#  Author: eweb
#  Copyright WBT Systems, 2006-2007
#  Contents: Remove unchanged versions, moving labels to predecessor
#
#******************************************************************************
#
# Date:          Author:  Comments:
# 22nd Jan 2007  eweb     Handle directories.
#  2nd Feb 2007  eweb     force y(es), n(o), t(ree)
#                         Differ only by a "File generated on" line.
#                         Check args, usage.
#

use strict;
use File::Basename;

# need to look at a branch and test whether the latest is the same as the previous
# if it is, then first move any labels
# then delete it....
# Problem of branches...

sub GetPredecessor( $ )
  {
    my ( $filever ) = @_;

    my $cmd = "cleartool desc -fmt \"%En\" \"$filever\"";
    my $name = `$cmd`;

    $cmd = "cleartool desc -fmt \"%PSn\" \"$filever\"";
    my $pred = `$cmd`;

    return "$name\@\@$pred";
  }

sub MoveLabelsToPredecessor( $$ )
  {
    my ( $filever, $labels ) = @_;

    my $pred = GetPredecessor( $filever );

    foreach my $label ( split(/ /, $labels ) )
      {
        #print "$label\n";
        my $cmd = "cleartool mklabel -replace $label \"$pred\"";

        print "$cmd\n";
        system( $cmd );
      }
  }

sub RemoveIfNoLabels( $$ )
  {
    my ($filever, $force) = @_;

    my $cmd = "cleartool desc -fmt \"%Nl\" \"$filever\"";
    print "$cmd\n";
    my $labels = `$cmd`;

    chomp($labels);

    print "Labels: [$labels]\n";

    if ( $labels ne "" )
      {
        # move the labels to predecessor
        MoveLabelsToPredecessor( $filever, $labels );
      }

    # check if they have all been moved
    $labels = `$cmd`;

    chomp($labels);

    print "Labels: [$labels]\n";

    if ( $labels eq "" )
      {
        my $userInput;
        if ( $force eq "y" )
          {
            $userInput = "y";
          }
        elsif ( $force eq "n" )
          {
            $userInput = "n";
          }
        else
          {
            if ( $force eq "t" )
              {
                system( "clearvtree \"$filever\"" );
              }
            print "Remove version y/n?";
            $userInput = <STDIN>;
            chomp $userInput;
          }
        if ( $userInput eq "y" )
          {
            $cmd = "cleartool rmver -force \"$filever\"";
            print "$cmd\n";
            system( $cmd );
          }
      }
  }

# U:\>cleartool find \esd\nonwebable\languages -name uploadstrings_it.dat -version !brtype(_NOT_A_BRANCH_) -print
# \esd\nonwebable\languages\uploadstrings_it.dat@@\main\0
# \esd\nonwebable\languages\uploadstrings_it.dat@@\main\1
# \esd\nonwebable\languages\uploadstrings_it.dat@@\main\73x_branch\0
# \esd\nonwebable\languages\uploadstrings_it.dat@@\main\CHECKEDOUT

sub Unchanged( $$$ )
  {
    my ( $filepath, $lastversion, $force ) = @_;
    my $cmd = "cleartool diff -options -status_only -pred \"$filepath\@\@$lastversion\"";
    print "$cmd\n";
    `$cmd`;

    if ( $? eq 0 )
      {
        print "SAME: $filepath\@\@$lastversion same as previous\n";
      }
    return $?;
  }
sub DisplayDiffs( $$$ )
  {
    my ( $filepath, $lastversion, $force ) = @_;
    # U:\>cleartool find \esd\nonwebable\languages -name uploadstrings_it.dat -version !brtype(_NOT_A_BRANCH_) -print
    #my $file = basename($filepath);
    #my $dir  = dirname($filepath);

    if ( Unchanged( $filepath, $lastversion, $force ) == 0 )
      {
        RemoveIfNoLabels( "$filepath\@\@$lastversion", $force );
        return;
      }

#    my $cmd = "cleartool diff -pred -serial -option -b \"$filepath\@\@$lastversion";
    my $cmd = "cleartool diff -pred -serial \"$filepath\@\@$lastversion";
    print "$cmd\n";
    my $differences = `$cmd`;

#    my $diff;
#    if ( open( $diff, "$cmd |") )
#      {
#        while ( <$diff> )
#          {
#            #chomp;
#            #\esd\templates\Home.tmpl@@
#            # so string
#            print;
#          }
#      }

    chomp($differences);

    if ( $differences eq 'Files are identical' )
      {
        print "[$differences]\n";
        #$cmd = "clearvtree \"$filepath\@\@$lastversion";
        #system( $cmd );
        RemoveIfNoLabels( "$filepath\@\@$lastversion", $force );
      }
    elsif ( $differences eq 'Directories are identical' )
      {
        print "[$differences]\n";
        #$cmd = "clearvtree \"$filepath\@\@$lastversion";
        #system( $cmd );
        RemoveIfNoLabels( "$filepath\@\@$lastversion", $force );
      }
    else
      {
        print "versions differ";
        my $linestoprint = 1;
        my $onlyByGeneratedDate = 1;
        my @diffs = split( /\n/, $differences );
        my $separator = "********************************";
        my $quotedsep = quotemeta $separator;
        foreach ( @diffs )
          {
            if ( /^$quotedsep/ ||
                 /^<<< file 1:/ ||
                 /^>>> file 2:/ ||
                 /^-----\[[0-9]+ changed to [0-9]+\]-----/ ||
                 /^---/
               )
              {
              }
            elsif ( /< \/\/  File generated on: / ||
                    /> \/\/  File generated on: / )
              {
              }
            elsif ( /< File generated on: / ||
                    /> File generated on: / )
              {
              }
            else
              {
                if ( $linestoprint > 0 )
                  {
                    print "[$_]\n";
                    $linestoprint--;
                  }
                $onlyByGeneratedDate = 0;
              }
          }
        if ( $onlyByGeneratedDate == 1 )
          {
            print " but only by generated date\n";
            RemoveIfNoLabels( "$filepath\@\@$lastversion", $force );
          }
        else
          {
            #print "[$differences]\n";
            print "\n";
          }
      }
  }

sub DisplayVersions( $$$ )
  {
    my ( $filepath, $branch, $force ) = @_;
    # U:\>cleartool find \esd\nonwebable\languages -name uploadstrings_it.dat -version !brtype(_NOT_A_BRANCH_) -print
    my $file = basename($filepath);
    my $dir  = dirname($filepath);

    my $cmd = "cleartool find \"$dir\" -name \"$file\" -version !brtype(_NOT_A_BRANCH_) -print";

    my $branched;
    my $find;
    my @versions;
    my $lastversion;

    print "$cmd\n";
    if ( open( $find, "$cmd |") )
      {
        while ( <$find> )
          {
            chomp;
            #\esd\templates\Home.tmpl@@
            # so string
            if ( /(.*)\@\@(.*)$/ )
              {
                my $filepath = $1;
                my $brpath = $2;
                #print "$brpath\n";
                if ( $brpath =~ /$branch\\([0-9]+)$/ )
                  {
                    # has versions on branch...
                    if ( $1 eq "0" )
                      {
                        #print "ZERO VERSION ON BRANCH: $brpath\n";
                      }
                    else
                      {
                        @versions = ( @versions, $1 );
                        #print "ON BRANCH: $brpath\n";
                        $lastversion = $brpath;
                      }
                  }
                elsif ( $brpath =~ /$branch\\(.*)$/ )
                  {
                    # has sub branches on branch...
                    #print "HAS SUBBRANCHES: $brpath\n";
                    $branched = "Y";
                  }
                else
                  {
                    # somewhere else altogether
                    #print "SOMEWHERE ELSE: $brpath\n";
                  }

                #$filepath = \esd\templates\Home.tmpl
                #DisplayVersions( $filepath, $branch );
              }
          }
        if ( $branched )
          {
            print "$file has subbranches\n";
          }
        else
          {
            #print "$file has versions " . ($#versions + 1). " @versions\n";
            if ( $#versions >= 0 )
              {
                DisplayDiffs( $filepath, $lastversion, $force );
              }
          }
      }
  }

# find all elements with a particular branch type

# e.g. esd_branch_AHIMA_733

sub RemoveUnchangedVersions( $$$ )
  {
    my ( $branch, $start, $force ) = @_;

    if ( $branch eq "" )
      {
        die "Usage: perl $0 branch start force\n";
      }

    if ( $start eq "" )
      {
        $start = ".";
      }

    my $cmd = "cleartool find $start -element brtype($branch) -print";

    print "$cmd\n";
    my $find;
    if ( open( $find, "$cmd |") )
      {
        while ( <$find> )
          {
            chomp;
            #\esd\templates\Home.tmpl@@
            # so string
            if ( /(.*)\@\@$/ )
              {
                my $filepath = $1;
                print "$filepath\n";
                #$filepath = \esd\templates\Home.tmpl
                DisplayVersions( $filepath, $branch, $force );
              }
          }
      }
  }

#sub RemoveUnchangedVersions( $$$ )
#  {
#    my ( $branch, $start, $force ) = @_;
#
#    while ( 1 )
#      {
#        my $filepath = ".";
#        print "$filepath\n";
#        DisplayVersions( $filepath, $branch, $force );
#      }
#  }

#my $branch = "esd_branch_AHIMA_733";
#my $start = ".";

RemoveUnchangedVersions( $ARGV[0], $ARGV[1], $ARGV[2] );

