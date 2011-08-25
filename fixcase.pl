use strict;
use File::Glob;
use File::Basename;

my $arg1 = $ARGV[0];
my $dir2 = $ARGV[1];

print "$arg1\n";

my ($wild, $dir1) = fileparse($arg1);

foreach ( File::Glob::bsd_glob( $arg1 ) ) {
  my $file1 = $_;
  $file1 =~ s!\Q$dir1\E!!;
  if ( -e "$dir2/$file1" ) {
    foreach ( File::Glob::bsd_glob( "$dir2/$file1*" ) ) {
      my $file2 = $_;
      $file2 =~ s!\Q$dir2/\E!!;
      if ( $file1 ne $file2 ) {
        if ( lc $file1 eq lc $file2 ) {
          print "$file1 and $file2 case\n";
          rename( "$dir1/$file1", "$dir1/$file2" );
        }
        else {
          print "ERROR! $file1 ne $file2\n";
        }
      }
    }
  }
}

