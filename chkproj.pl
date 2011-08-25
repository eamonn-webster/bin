use strict;
use File::Glob;

if ( @ARGV == 0 ) {
  print "Usage: chkproj.pl files\n";
}
else {
  while ( <@ARGV> ) {
    my $file = $_;
    print $file . "\n";
    if ( open( IN, $file ) ) {
      my $lno = 0;
      while ( <IN> ) {
        my $line = $_;
        if ( $line =~ /RelativePath="(.+)"/ ) {
          my $src = $1;
          #my @globbed = File::Glob::bsd_glob($src);
          #if ( scalar @globbed ) {
          my $dir = `cmd /c dir /s /b $src`;
          chomp($dir);
          #my $namedir = $dir;
          $dir =~ s!.*\\!!;
          $src =~ s!.*\\!!;
          #print "dir[$dir] src[$src]\n";
          if ( $dir =~ /$src$/ ) {
          }
          elsif ( $dir =~ /$src$/i ) {
            print "File: $src wrong case $dir\n";
          }
          else {
            print "File: $src not found\n";
          }
        }
      }
      close( IN );
    }
  }
}
