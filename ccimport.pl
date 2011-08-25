use strict;
use File::Find;
use File::Basename;
use Cwd;

my $verbose = 1;

sub ccIsDir {
  my ($dir) = @_;
  #return undef(); # ( -d $dir );

  my $cmd = "cleartool desc -fmt \"%m\" \"$dir\"";
  print "cmd: $cmd\n" if ( $verbose );
  my $res = `$cmd`;
  return ( $res eq "directory version" );
}

sub ccIsFile($) {
  my ($file) = @_;
  return ( -e $file );
  my $cmd = "cleartool desc -fmt \"%m\" \"$file\"";
  print "cmd: $cmd\n" if ( $verbose );
  my $res = `$cmd`;
  return ( $res eq "version" );
}

sub ccMkDir($) {
  my ($dir) = @_;
  my $cmd = "cleartool mkdir -nc \"$dir\"";
  #$cmd = "mkdir \"$dir\"";
  print "cmd: $cmd\n" if ( $verbose );
  my $res = `$cmd`;
  print "$res\n" if ( $verbose );
}

sub ccMkFile($) {
  my ($file) = @_;
  #my $cmd = "cleartool mkelem -nc \"$file\"";
  #print "cmd: $cmd\n" if ( $verbose );
  #my $res = `$cmd`;
  #print "$res\n" if ( $verbose );
}

sub RmDir($) {
  my ($dir) = @_;
  my $cmd = "rmdir \"$dir\"";
  print "cmd: $cmd\n" if ( $verbose );
  my $res = `$cmd`;
  print "$res\n" if ( $verbose );
}

sub MoveFile($$) {
  my ($src, $dest) = @_;
  my $cmd = "move \"$src\" \"$dest\"";
  print "cmd: $cmd\n" if ( $verbose );
  my $res = `$cmd`;
  print "$res\n" if ( $verbose );
}

sub wanted {
  #$File::Find::dir  = /some/path/
  #$_                = foo.ext
  #$File::Find::name = /some/path/foo.ext

  my $file = $_;
  my $path = $File::Find::name;

  if ( $file eq "." or $file eq ".." ) {
  }
  elsif ( -d $file ) {
    print "DIR: $path\n";
    print "CWD: " . getcwd() . "\n";
    if ( ccIsDir( $file ) ) {
    }
    else {
      MoveFile( $file, "$file.x" );
      ccMkDir( $file );
      if ( opendir( DIR, "$file.x" ) ) {
        my $f;
        while ( defined( $f = readdir(DIR) ) ) {
          if ( $f ne "." and $f ne ".." ) {
            MoveFile( "$file.x\\$f", "$file" );
          }
        }
        closedir(DIR);
      }
      RmDir( "$file.x" );
    }
  }
  elsif ( -e $file ) {
    #print "FILE: $path\n";
    if ( ccIsFile( $file ) ) {
    }
    else {
      ccMkFile( $file );
    }
  }
}


my $start = $ARGV[0];
$start = "." unless ( $start );

my @directories_to_search = ( $start );

find(\&wanted, @directories_to_search);



