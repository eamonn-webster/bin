# copy-git-privs.pl

use strict;
use File::Basename;


my $cmd = "git clean -n -d";

my $safe = "c:/cpp/safe/tc800/";
$safe =~ s!/!\\!g;

if ( open( PRIVS, "$cmd |" ) ) {
  while ( <PRIVS> ) {
    if ( /Would remove (.+)/ ) {
      my $full = $1;
      $full =~ s!/!\\!g;
      my ($name, $path) = fileparse($full);


      $cmd = "xcopy /i \"$path$name\" \"$safe$path\"";
      print "$cmd\n";
      system( $cmd );
    }
  }
}
