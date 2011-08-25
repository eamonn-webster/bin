use strict;
use Getopt::Std;
use File::Basename;
use Term::ReadKey;
use File::Glob;
use File::Copy;

my %opts = ( a => undef(),
             s => undef(),
             v => undef(),
           );

if ( !getopts("a:s:v:", \%opts) or @ARGV > 1 ) {
    print STDERR "Unknown arg $ARGV[0]\n" if @ARGV > 0;
    #Usage();
    exit;
}

my $verbose = $opts{v};
my $start = $opts{s};
my $action = $opts{a};

$start = "." unless( $start );

sub dosify($) {
  my ($path) = @_;
  $path =~ s!/!\\!g;
  return $path;
}

sub dedosify($) {
  my ($path) = @_;
  $path =~ s!\\!/!g;
  return $path;
}

sub osify($) {
  my ($path) = @_;
  if ( $^O eq "MSWin32" ) {
    $path =~ s!/!\\!g;
  }
  else {
    $path =~ s!\\!/!g;
  }
  return $path;
}

sub getchar() {
  my $char;
  ReadMode('cbreak');

  #while (1) {
    $char = ReadKey(0);
  #  last unless defined $char;
  #  printf(" Decimal: %d\tHex: %x\n", ord($char), ord($char));
  #}

  ReadMode('normal');
  return $char;
}

sub MkDir($) {
  my ($dir) = @_;
  if ( -d $dir ) {
    #print "MkDir $dir exists\n";
  }
  else {
    my $sofar = "";
    foreach ( split( /[\\\/]/, $dir ) ) {
      if ( $sofar eq "" ) {
        $sofar = $_;
      }
      else {
        $sofar = osify("$sofar/$_");
        if ( -d $sofar ) {
          #print "MkDir $sofar exists\n";
        }
        else {
          #print "calling mkdir( $sofar )\n";
          if ( mkdir( $sofar ) ) {
            #print "MkDir $dir succeeded\n";
          }
          else {
            print "MkDir $sofar FAILED! $!\n";
            return 0;
          }
        }
      }
    }
    #print "MkDir $dir\n";
  }
}

sub copyFile($$;$) {
  my ($source, $dest, $flags) = @_;

  $source = osify($source);
  $dest = osify($dest);

  print "copy $flags $source $dest\n";

  my ($nameS, $pathS, $suffixS) = fileparse($source);
  my ($nameD, $pathD, $suffixD) = fileparse($dest);

  #print "Source ($nameS, $pathS, $suffixS)\n";
  #print "Dest   ($nameD, $pathD, $suffixD)\n";

  if ( $flags eq "/p" ) {
    if ( !-d $pathD ) {
      MkDir( $pathD );
    }
  }

  if ( -e $dest ) {
    # copying to a file that exists?
  }
  if ( -e $source ) {
    my $destFile = $dest;
    if ( -d $dest ) {
      # copying to a directory
      $destFile = osify("$dest/$nameS$suffixS");
    }
    elsif ( $nameD eq "" ) {
      #destination is a directory
      MkDir( $dest );
      $destFile = osify("$dest/$nameS$suffixS");
    }
    else {
      if ( $nameS =~ /\./ ) {
        if ( $nameD !~ /\./ ) {
          print "**** Perhaps destination $dest is a directory\n";
        }
      }
    }
    if ( copy( $source, $destFile ) ) {
      print "$source => $destFile\n";
    }
    else {
      print "**** $source => $destFile FAILED $!\n";
    }
  }
  elsif ( -d $source ) {
    print "?????? copy directory $source $dest\n";
  }
  elsif ( $source =~ /[\?\*]/ ) { # globbing
    print "copy glob $source $dest\n";
    my @sources = File::Glob::bsd_glob( $source );
    if ( $#sources == 0 ) {
      print "**** $source no files\n";
    }
    else {
      MkDir( $dest );
      foreach (@sources) {
        my ($name, $path, $suffix) = fileparse($_);
        my $destFile = osify("$dest/$name$suffix");
        if ( copy( $_, $destFile ) ) {
          print "$_ => $destFile\n";
        }
        else {
          print "**** $_ => $destFile FAILED $!\n";
        }
      }
    }
  }
  else {
    print "**** $source file not found\n";
  }

  if ( $flags eq "/s" or $flags eq "/e" ) {
    my ($name, $srcDir, $suffix) = fileparse($source);
    my $dir;
    if ( opendir( $dir, $srcDir) ) {
      my $subdir;
      while ( defined( $subdir = readdir($dir) ) ) {
        if ( $subdir eq "." or $subdir eq ".." ) {
        }
        elsif ( -d "$srcDir$subdir" ) {
          copyFile( osify("$srcDir$subdir/$name$suffix"), osify("$dest/$subdir"), $flags );
        }
      }
      closedir($dir);
    }
  }
}

if ( $start eq "-avobs" ) {
  $start = "-avobs -visible"
}
my $mypath = (fileparse($0))[1];

my $linksdat = osify("${mypath}links.dat");

if ( $action eq "search" ) {
  my $cmd = "cleartool find $start -type l -print";

  if ( open( LINKS, "$cmd |" ) ) {
    if ( open( LINKDSDAT, ">$linksdat" ) ) {
      while ( <LINKS> ) {
        chomp;
        my $link = $_;
        $cmd = "cleartool desc -fmt \"%[slink_text]p\" $link";
        my $target = `$cmd`;
        $link = dedosify($link);
        $target = dedosify($target);

        #print "$link ==> $target\n";

        my ($linkName, $linkDir) = fileparse($link);

        $target = $linkDir . $target;

        #print "$link ==> $target\n";

        while ( $target =~ s![^/]+/\.\./!! ) {

        }

        #W:/topclass/oracle/topclass/../../../utils/AutoDevBuild/bin/xmltostring.pl

        print LINKDSDAT "$link\t$target\n";
        #if ( -e $link and -e $target ) {
        #}
      }
      close( LINKSDAT );
    }
    close( LINKS );
  }
}
else {
  if ( open( LINKSDAT, $linksdat ) ) {
    while ( <LINKSDAT> ) {
      chomp;
      my ($link, $target) = split(/\t/);
      #print "$link => $target\n";
      if ( -d $link or -d $target ) {
      }
      elsif ( -e $link and -e $target ) {
        #print "both exit\n";

        while ( 1 ) {
          my $cmd = "diff --binary --brief ";
          $cmd .= '"' . osify($link) . '"';
          $cmd .= ' ';
          $cmd .= '"' . osify($target) . '"';
          my $diff = `$cmd`;
          if ( $diff eq "" ) {
            #print "[$diff]\n";
            last;
          }
          else {
            print "[$diff]\n";

            # do a windiff...

            my $cmd = "windiff ";
            $cmd .= '"' . osify($link) . '"';
            $cmd .= ' ';
            $cmd .= '"' . osify($target) . '"';
            system( $cmd );
            print "$link => $target\n";
            print "copy (y/n/b):";
            my $ch = getchar();
            if ( $ch eq "y" ) {
              copyFile( $link, $target );
            }
            elsif ( $ch eq "b" ) {
              copyFile( $target, $link );
            }
            elsif ( $ch eq "n" ) {
            }
            elsif ( $ch eq "q" ) {
            }
            else {
              next;
            }
            last;
          }
        }
      }
      else {
        if ( !-e $link and !-e $target ) {
          print "$link => $target source doesn't exist\n" if ( $verbose );
        }
        elsif ( !-e $link ) {
          print "$link => $target source doesn't exist\n";
        }
        elsif ( !-e $target ) {
          print "$link => $target target doesn't exist\n" if ( $verbose );
        }
      }
    }
    close( LINKSDAT );
  }
}
