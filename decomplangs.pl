#
# File: decomplangs.pl
# Author: eweb
# Copyright WBT Systems, 1995-2008
# Contents:
#
# Date:          Author:  Comments:
#  9th Dec 2008  eweb     #00008 Script to decompile and checkin language files
# Purpose : To decompile .lang files into .dats.


# Usage:
#
# perl decomplangs.pl <langdir> <datdir> <comment>
#
# by default will check files out but not check them in again...
# to get them checked in set $level = 2;
#
# Will write all strings including those appended from the usenglish .dat file
# Will write as utf-8 with a BOM.
#

use strict;

my %map;
my %checkouts;

my $langdir = $ARGV[0];
my $datdir  = $ARGV[1];
my $comment = $ARGV[2];

my $cctool0 = "echo cleartool"; # safe info  ls, desc
my $cctool1 = "echo cleartool"; # safish undoable checkout
my $cctool2 = "echo cleartool"; # not so safe checkin/uncheckout
my $cctool3 = "echo cleartool"; # dangerous rmelem, rmlable, rmbranch

$langdir = "." if ( $langdir eq "" );
$datdir  = "." if ( $datdir eq "" );
$comment = "#00003 Strings" if ( $comment eq "" );

my $level = 1;
if ( $level ge 0 ) {
  $cctool0 = "cleartool"; # safe info  ls, desc
}
if ( $level ge 1 ) {
  $cctool1 = "cleartool"; # safish undoable checkout
}
if ( $level ge 2 ) {
  $cctool2 = "cleartool"; # not so safe checkin/uncheckout
}
if ( $level ge 3 ) {
  $cctool3 = "cleartool"; # dangerous rmelem, rmlable, rmbranch
}

if ( opendir( DIR, $datdir ) ) {
  my $file;
  while ( defined( $file = readdir(DIR) ) ) {
    my $full = "$datdir/$file";
    $full =~ s!/!\\!g;              # do slashes
    if ( $file =~ /\.dat$/ ) {
      #print "$file\n";
      if ( open( DAT, $full ) ) {
        while ( <DAT> ) {
          if ( /;Filename=(.+)\.lang/ ) {
            $map{$1} = $file;
            last;
          }
        }
        close( DAT );
      }
      else {
        print "failed to open $full\n";
      }
    }
  }
  closedir(DIR);
}


my %langmap = (
    ukenglish =>         "_uk",
    usenglish =>         "",
    french  =>           "_fr",
    german  =>           "_de",
    danish  =>           "_dk",
    dutch =>             "_du",
    italian =>           "_it",
    spanish =>           "_es",
    portuguese  =>       "_pt",
    russian =>           "_ru",
    polish  =>           "_pl",
    greek =>             "_el",
    gallegan  =>         "_gl",
    chinese =>           "_zh",
    thai  =>             "_th",
    japanese  =>         "_ja",
    Hindi =>             "_hi",
    Korean  =>           "_ko",
    BahasaIndonesia =>   "_id",
    BahasaMelayu  =>     "_ms",
    Turkish =>           "_tr",
    Arabic  =>           "_ar",
    simplifiedChinese => "_sz",
);

if ( opendir( DIR, $langdir ) ) {
  my $file;
  while ( defined( $file = readdir(DIR) ) ) {
    my $full = "$langdir/$file";
    $full =~ s!/!\\!g;              # do slashes
    if ( $file =~ /^(.+)\.lang$/ ) {
    #if ( $file =~ /^(qpi_U.+)\.lang$/ ) { # use this to just process
      my $lang = $1;
      my $dat = $map{$lang};
      if ( $dat eq "" ) {
        print "ERROR: NO dat file for $lang.lang\n";
        if ( $lang =~ /^(.+)_([^_]+)$/ ) {
          my $code = $langmap{$2};
          $dat = $1 . $code . '.dat';
        }
        else {
          print "ERROR: can't determine language of $lang.lang\n";
          $dat = "$lang.dat";
        }
      }
      my $lab = $dat;
      $lab =~ s!_..\.dat$!.dat!;

      my $labels = "$lang.labels";
      $labels =~ s!_[^_]+\.labels$!.labels!;
      #print "$1 => " . $map{$lang} . "\n";

      my $cmd = "langutils $langdir\\$lang.lang $datdir\\$dat.new";
      if ( -e "$langdir\\$labels" ) {
        print "Labels file: $langdir\\$labels found\n";
        $cmd = "$cmd -L$langdir\\$labels";
      }
      else {
        print "Labels file: $langdir\\$labels not found\n";
      }
      if ( -e "$datdir\\$lab" ) {
        $cmd = "$cmd -L$datdir\\$lab";
      }
      #print "$cmd\n";
      runCmd( $cmd );
      # compare $datdir\\$dat.new and $datdir\\$dat
      # or perhaps just check out and copy over.
      checkOut( "$datdir\\$dat", $comment );
      runCmd( "copy /y $datdir\\$dat.new $datdir\\$dat" );
      checkIn( "$datdir\\$dat", $comment );
    }
  }
  closedir(DIR);
}

sub runCmd( $$ ) {
  my ($cmd, $where) = @_;
  $where = 0 if ( $where eq "" );

  print "$cmd\n" unless ( $where & 1 );
  #print $BuildLog encode_entities($cmd) . "\n" unless ( $where & 2 );
  my $h;
  if ( open( $h, "$cmd 2>&1 |" ) ) {
    while ( <$h> ) {
      print unless ( $where & 1 );
      #print $BuildLog encode_entities($_) unless ( $where & 2 );
    }
    close( $h );
  }
}

sub checkIn($$)
  {
    my ($file, $comment) = @_;

    my $cmd = "$cctool2 ci -c \"$comment\" $file";
    print "$cmd\n";
    my $results = `$cmd 2>&1`;

    if ( $results =~ /Error: By default, won\'t create version with data identical to predecessor./ )
      {
        # hasn't changed so undo the check out.
        print " - unchanged undoing checkout";
        $cmd = "$cctool2 unco -rm $file";
        $results = $results . "\n" . $cmd . "\n" . `$cmd 2>&1`;
      }
    elsif ( $results =~ /Error: Not an element:/ )
      {
        print " - Not an element";
        # Not an element
      }
    elsif ( $results =~ /Error:/ )
      {
        print " - Error";
        # Not an element
      }
    else
      {
        # Not an element
      }

    print "$results\n";
  }

sub checkOut($$)
  {
    my ($file, $comment) = @_;

    $checkouts{$file} = $comment;

    my $cmd = "$cctool1 co -c \"$comment\" $file";

    print "$cmd\n";

    my $results = `$cmd 2>&1`;

    if ( $results =~ /Error: Element "(.+)" is already checked out to view "(.+)"/ )
      {
        print "already checked out";
      }
    elsif ( $results =~ /Error: Not a vob object:/ )
      {
        # Not an element
        print " - Not a vob object";
      }
    elsif ( $results =~ /Error: / )
      {
        print " - Error";
      }
    print "$results\n";
  }


