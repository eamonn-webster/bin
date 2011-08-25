#!/usr/bin/perl
#
# File: getcomments.pl
# Author: eweb
# Copyright WBT Systems, 1995-2010
# Contents:
#
# Date:          Author:  Comments:
# 24th Feb 2010  eweb     #00008 Scrape comments from files
#

use strict;
use Getopt::Std;
use Cwd;

my @comments;

my %opts = ( s => undef(),
             l => undef(),
             v => undef(),
             d => undef(),
             t => undef(),
           );

# Was anything other than the defined option entered on the command line?
if ( !getopts("s:l:v:d:t:", \%opts) or @ARGV > 1 ) {
    print STDERR "Unknown arg $ARGV[0]\n" if @ARGV > 0;
    #Usage();
    exit;
}

my $cwd = getcwd();
my $drive = "c:";
if ( $cwd =~ /^([a-z]:)/i ) {
  $drive = $1;
}
if ( defined( $opts{d} ) ) {
  $drive = $opts{d};
}
my $verbose = $opts{v};
my $scc = $opts{s};
my $rev = $opts{l};
my $test = $opts{t};

sub determinescc() {
  if ( $scc eq "" ) {
    if ( $cwd =~ /^c:\/p4clients/i or $cwd =~ /^c:\\p4clients/i ) {
      $scc = "p4";
    }
    elsif ( -d "\\.git" or -d ".git" ) {
      $scc = "git";
    }
    elsif ( -d "\\.svn" or -d ".svn" ) {
      $scc = "svn";
    }
    elsif ( $cwd =~ /^c:\/cpp/i or $cwd =~ /^c:\\cpp/i ) {
      $scc = "escc";
    }
    else {
      $scc = "clearcase";
    }
  }
  if ( $scc eq "git" and $rev eq "" ) {
    $rev = "HEAD";
  }
}
sub formatDate($$$) {
  my ($d, $m, $y) = @_;

  #my $Month = @Months[$Mon];
  #$Mon = $Mon + 1;

  my $Th = "th";
  $d++;
  $d--;
  if ( $d == 1 || $d == 21 || $d == 31 ) {
    $Th = "st";
  }
  elsif ( $d == 2 || $d == 22 ) {
    $Th = "nd";
  }
  elsif ( $d == 3 || $d == 23 ) {
    $Th = "rd";
  }
  if ( $d < 10 ) {
    $d = " $d";
  }

  return "$d$Th $m $y";
}
sub onefile($$$) {

  my ($file, $since, $out) = @_;
  #print "onefile($file, $since, $out)\n";

  print "$file\n" if ( $verbose );
  # got the changes, open the file and see if they are within range.

  my $diffcmd;
  if ( $scc eq "git" ) {
    $diffcmd = "git diff $since -- $file";
  }
  elsif ( $scc eq "p4" ) {
    $diffcmd = "p4 diff -du $file";
  }
  elsif ( $scc eq "clearcase" ) {
    $diffcmd = "cleartool diff -diff -pred $file";
  }
  elsif ( $scc eq "svn" ) {
    $diffcmd = "svn diff $file";
  }
  print "$diffcmd\n" if ( $verbose );
  if ( open( DIFF, "$diffcmd 2>&1 |" ) ) {
    my @oldComments;
    my $l = 0;
    while ( <DIFF> ) {
      #chomp();
      s!\r|\n$!!;
      $l++;
      # deal with the file.
      #print;
      # TODO 1) the add indicator + for git and svn, > for clearcase
      # TODO 2) the single prefix null, #, -- depening on file type
      # TODO 3) the history item
      if ( /^(\+|-|> )(#|--)? +([0-9]+)(st|nd|rd|th)? +([A-Z][a-z]+) +([0-9]+) +([^ ]+) +(#[0-9?]+.*)/ ) {
        #print "$file: $_\n" if ( $verbose );
        #print $file if ( $verbose );
        print "[$_]\n" if ( $verbose );
        my $mark = $1;
        my $day = $3;
        my $month = $4;
        my $year = $6;
        my $user = $7;
        my $comment = $8;
        #print "$comment\n";
        if ( $comment =~ /(#[^ ]+) *(.*)/ ) {
          my $bugid = $1;
          my $text = $2;
          $text =~ s!^\s+!!;
          $text =~ s!\s+$!!;
          if ( $mark eq "-" ) {
            print "saving [$bugid $text]\n" if ( $verbose );
            @oldComments = (@oldComments, "$bugid $text");
          }
          else {
            print "looking for [$bugid $text] in (@oldComments)\n" if ( $verbose );
            if ( !grep( /^\Q$bugid $text\E$/, @oldComments ) ) {
              #print "$bugid [$text]\n";
              print $out "rem addcomment.pl -c \"$comment\" \"$file\"\n";
              if ( !grep( /^\Q$comment\E$/, @comments ) ) {
                @comments = ( @comments, $comment );
              }
            }
          }
        }
      }
      else {
        if ( /^ / && @oldComments ) {
          print "$l: $_\n" if ( $verbose );
          print "clearing oldComments\n" if ( $verbose );
          @oldComments = ();
        }
      }
    }
    close( DIFF );
  }
}

sub comments($) {
  my $out = shift;
  my $cmd;
  my $since;
  if ( $scc eq "git" ) {
    $since = "$rev";
    $cmd = "git diff --name-only $since";
  }
  elsif ( $scc eq "p4" ) {
    $cmd = "p4 diff -sa";
  }
  elsif ( $scc eq "clearcase" ) {
    $cmd = "cleartool lsco -cview -avobs -short";
    #$cmd = "dir /b *.pl";
  }
  elsif ( $scc eq "svn" ) {
    $cmd = "svn status -q";
    #$cmd = "dir /b *.pl";
  }
  print "$cmd\n";
  if ( open( CHANGED, "$cmd 2>&1 |" ) ) {
    while ( <CHANGED> ) {
      chomp();
      # deal with the file.

      if ( $scc eq "svn" ) {
        if ( /^[AM].......(.+)/ ) {
          $_ = $1;
        }
        else {
          next;
        }
      }
      onefile($_, $since, $out);
    }
    close( CHANGED );
  }
  @comments = sort( @comments );
  @comments = reverse( @comments );
  foreach ( @comments ) {
    print $out "REM $_\n";
  }
}

determinescc();

if ( $test ) {
# problem caused by a change (trailing space) on an old comment line.
#     8th Apr 2009  deesy    #11560 can't see member non member prices and other xtra fields for offering
#-                           #00007 refactoring, remove unnecessary code
#-    9th Apr 2009  deesy    #11444 currency must have a value
#+                           #00007 refactoring, remove unnecessary code
#+    9th Apr 2009  deesy    #11444 currency must have a value
#    22nd Jul 2009  lisa     #11769 Java Error when saving offering that has non MemberPrice and MemberPrice specified as null in DB
  chdir( "c:/cpp/tc800" );
  $scc = "git";
  my $f = "topclass/java/cnr/src/com/wbtsystems/cnr/action/EditILTCatalogAction.java";
  my $since = "TC_800_BUILD_132";
  my $out = *STDOUT;
  #$verbose = 1;
  onefile($f, $since, $out);
  exit;
}

my $output = lc $drive;
$output =~ s/://g;
$output =~ s![/\\]!-!g;
$output = $ENV{TEMP} . "\\$output-comments.bat";
print " textpad $output\n\n";

my $cmts;
if ( open( $cmts, ">$output" ) ) {
  comments( $cmts );
  close( $cmts );
}
