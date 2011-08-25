use strict;
use File::Basename;

my $cmd = "git status";


if ( open(STATUS, "$cmd |") ) {
  my $section;
  while ( <STATUS> ) {
    if ( /# Untracked files:/ ) {
      $section = "untracked";
    }
    if ( $section eq "untracked" ) {
      if ( /#\t(.+)$/ ) {
        my $file = $1;
        if ( $file =~ /\.gitignore$/ ) {
        }
        else {
          $file =~ s!/$!!;
          my ($name,$path) = fileparse($file);
          #print "$path $name\n";
          #if ( open( IGNORE, ">>$path.gitignore" ) ) {
          #  print IGNORE "$name\n";
          #  close( IGNORE );
          #}
          $path =~ s!/!\\!g;
          print "echo $name>> \\$path.gitignore\n";
        }
      }
    }
  }
  close(STATUS)
}
