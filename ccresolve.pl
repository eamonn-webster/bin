#for each file if it is only on the 900_branch
#i.e. main\LATEST = main\0
#
#cleartool find . -version "version(main\LATEST) && version(main\0)" -print
#
#is there a file with the same name on main\LATEST
#
#if so we need to reuse the element from main.
#

use strict;
use File::Basename;

my $dir1 = $ARGV[0];
my $dir0 = $ARGV[1];

if ( $dir0 eq "" ) {
  $dir0 = ".";
}

my $cmd = "cleartool find $dir0 -version \"version(main\\LATEST) && version(main\\0)\" -print";

if ( open( newOnBranch, "$cmd |" ) ) {
  while ( <newOnBranch> ) {

    chomp;

    if ( /(.+)\@\@(.+)/ ) {
      my ($file, $version) = /(.+)\@\@(.+)/;
      if ( -d $file ) {
      }
      else {
        my ($name, $path, $ext) = fileparse($file);

        #print "$name in $path\n";
        $cmd = "dir /s /b $dir1\\$name";
        #print "Cmd: $cmd\n";
        if ( open( DIR, "$cmd  2>&1 |" ) ) {
          while ( <DIR> ) {
            print "$name in $path also at $_" unless ( /File Not Found/ );
          }
        }
       }
    }
  }
}

