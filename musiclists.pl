use strict;
use File::Find;

sub wanted {
  #$File::Find::dir  = /some/path/
  #$_                = foo.ext
  #$File::Find::name = /some/path/foo.ext

  my $file = $_;
  my $path = $File::Find::name;

  if ( $file eq "." or $file eq ".." ) {
  }
  elsif ( -d $file ) {
    $path =~ s!^.:/Documents and Settings/eweb/My Documents/My Music/!!;
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
  my $driveLetter;
  if ( $drive =~ /(.):/ ) {
    $driveLetter = $1;
  }
  if ( open( OUT, ">c:/temp/$driveLetter-music.lst" ) ) {
    my @directories_to_search = ( "$drive/Documents and Settings/eweb/My Documents/My Music" );

    find(\&wanted, @directories_to_search);
    close( OUT );
  }
}

listForDrive( $drive );
