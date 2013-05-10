#!/usr/bin/env perl
use strict;
use File::Find;

my @directories_to_search;

sub wanted {
  #$File::Find::dir  = /some/path/
  #$_                = foo.ext
  #$File::Find::name = /some/path/foo.ext

  my $file = $_;
  my $path = $File::Find::name;

  if ( $file eq "." or $file eq ".." ) {
  }
  elsif ( -d $file ) {
    for my $root (@directories_to_search) {
      $path =~ s!$root/!!;
    }
    #$path =~ s!^.:/Documents and Settings/eweb/My Documents/My Music/!!;
    if ( $path =~ /\// ) {
      #print "$path\n";
      print OUT "$path\n";
    }
  }
  elsif ( -e $file ) {
  }
}


my $drive = $ARGV[0];

sub listForDrive($) {
  my ($drive) = @_;
  my $outfile = "c:/temp/$drive-music.lst";
  my $outfile = "$ENV{HOME}/tmp/$drive-music.lst";
  print "$outfile\n";
  if ( open( OUT, ">$outfile" ) ) {
    @directories_to_search = ( "$drive/Documents and Settings/eweb/My Documents/My Music" );
    @directories_to_search = ( "$ENV{HOME}/Music/iTunes/iTunes Media/Music" );
    print "@directories_to_search\n";
    find(\&wanted, @directories_to_search);
    close( OUT );
  }
}

listForDrive( $drive );
