use strict;
use File::Find;

my $root = "C:/cygwin/http%3a%2f%2fftp.esat.net%2fmirrors%2fsources.redhat.com%2fpub%2fcygwin%2f/release";

sub wanted {
  #$File::Find::dir  = /some/path/
  #$_                = foo.ext
  #$File::Find::name = /some/path/foo.ext

  my $file = $_;
  my $path = $File::Find::dir;
  my $full = $File::Find::name;

  #my $relpath = $path;
  $path =~ s!^$root!!;
  print "path:$path file:$file\n";
  #my $src = osify($full);
  #my $dst = osify($full);
  #my $dstdir = osify($path);

  #my $srcRoot = osify($scriptsDir);
  #my $dstRoot = osify($tcpath);

  #print "src:$src dst:$dst\n" if ( $verbose );

  #print "srcRoot:$srcRoot dstRoot:$dstRoot\n" if ( $verbose );
  #$srcRoot = quotemeta($srcRoot);
  ##$dstRoot = quotemeta($dstRoot);

  #$dst =~ s!$srcRoot!$dstRoot!;
  #$dstdir =~ s!$srcRoot!$dstRoot!;
  #print "src:$src dst:$dst\n" if ( $verbose );

  #if ( $full eq "." ) {
  #  # create empty directories.
  #  if ( !-d $dstdir ) {
  #    mkdir( $dstdir );
  #  }
  #}
  #elsif ( $full eq ".." ) {
  #}
  #elsif ( -e $full && $full =~ /\.sql$/ ) {
  #  if ( !-d $dstdir ) {
  #    mkdir( $dstdir );
  #  }
  #  print "copy($src, $dst)\n" if ( $verbose );
  #  copy($src, $dst);
  #}
}

find(\&wanted, $root);

