use strict;
use File::Basename;


my $ver1 = $ARGV[0];
my $ver2 = $ARGV[1];
my $start = $ARGV[2];

$ver1 = "800:102" unless ( $ver1 );
$ver2 = "800:100" unless ( $ver2 );
$start  = "-avobs" unless ( $start );

my ($mnp1, $b1) = split( /:/, $ver1 );
my ($mnp2, $b2) = split( /:/, $ver2 );

my $label1 = "TC_${mnp1}_BUILD_$b1";
my $label2 = "TC_${mnp2}_BUILD_$b2";
my $dest   = "c:\\temp\\diff${mnp2}b${b2}_and_${mnp1}b${b1}";
# $start  = ".";

# -version "lbtype(label2) && !lbtype(label1)"
# -version "!lbtype(label2) && lbtype(label1)"

my $cmd = "cleartool find $start -cview -version \"lbtype($label1) && !lbtype($label2)\" -print";
print "$cmd\n";

if ( open( CHANGES, "$cmd |" ) ) {
  while ( <CHANGES> ) {
    print;
    chomp;
    if ( -d ) {
    }
    elsif ( -e ) {
      my $version = $_;
      my $element;
      my $view;
      my $path;
      if ( $version =~ /^(M:\\([^\\]+)\\([^@]+))\@\@/ ) {
        $element = $1;
        $view = $2;
        $path = $3;
      }
      elsif ( $version =~ /^((.):\\([^@]+))\@\@/ ) {
        $element = $1;
        $view = $2;
        $path = $3;
      }
      elsif ( $version =~ /^\.\\([^@]+)\@\@/ ) {
        $element = $1;
        #$view = $2;
        $path = $1;
      }
      if ( $element ) {
        my ( $file, $dir ) = fileparse( $path );
        my $xcopy = "xcopy /i /y \"$element\" \"$dest\\$dir\"";
        print "$xcopy\n";
        system( $xcopy );
      }
    }
  }
  close( CHANGES );
}
