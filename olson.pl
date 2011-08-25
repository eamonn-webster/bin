#!/usr/bin/perl
#
# File: olson.pl
# Author: eweb
# Copyright WBT Systems, 1995-2011
# Contents:
#
# Date:          Author:  Comments:
# 29th Sep 2010  eweb     #12612 scripts and exes
# 16th Feb 2011  eweb     #00008 Improvements
#

use strict;
use File::Temp qw/tempfile/;
use File::Copy;
use Getopt::Std;
use Cwd;

my %opts = ( d => undef(),
             m => undef(),
             n => undef(),
             p => undef(),
             b => undef(),
             v => undef(),
             S => undef(),
             D => undef(),
             V => undef(),
#             w => undef(),
#             o => undef(),
           );

if ( !getopts("d:m:n:p:b:v:S:D:V:", \%opts) or @ARGV > 1 ) {
  print STDERR "Unknown arg $ARGV[0]\n" if @ARGV > 0;
  Usage();
  exit;
}

sub Usage() {
  print "Usage: $0 <options>\n";
  print " -d drive\n";
  print " -m major\n";
  print " -n minor\n";
  print " -p point\n";
  print " -b build\n";
  print " -v verbose\n";
#  print " -w what (both|oracle|mssql|both)\n";
#  print " -o output\n";

}

my $drive = $opts{d};

my $verbose = $opts{v};
my $view = $opts{V};

my $stages = $opts{S};
my $stage1 = ($stages =~ /1/); # download and extract
my $stage2 = ($stages =~ /2/); # copy to clearcase
my $stage3 = ($stages =~ /3/); # check in and label
my $stage4 = ($stages =~ /4/); # build exes
my $stage5 = ($stages =~ /5/); # generate zoneinfo data files
my $stage6 = ($stages =~ /6/); # generate .ics files

my $distro = $opts{D};
#$distro = "2010m" unless ( $distro );

unless ( $view )
  {
    # need to determine the current view and drive
    my $cmd = "cleartool lsview -cview -short";
    chomp( $view = `$cmd` ); #e.g. eweb_800_hogfather

    print "[$cmd] => [$view]\n" if ( $verbose );
    #print "[$view]\n";
    if ( $view =~ /Error escc: unknown command lsview/ )
      {
        $view = "";
      }
    if ( $view eq $cmd )
      {
        $view = "";
      }
    #print "[$View]\n";
    if ( $drive eq "" )
      {
        my $dir = cwd;
        if ( $dir =~ /^(.:)/ )
          {
            $drive = $1;
          }
      }
  }

print "\$view: $view\n";

my $olson_temp = osify("c:/temp/olson");
my $olson_dir = osify("$drive/topclass/oracle/topclass/sources/tz" );

my $vzic = osify("$drive/utils/AutoDevBuild/bin/vzic.exe");
#$vzic = osify("c:/bin/vzic.exe");
$vzic = osify("$drive/3rdparty/Tools/vzic/vzic.exe");
my $zic = osify("$drive/utils/AutoDevBuild/bin/zic.exe");

if ( !-d $olson_temp ) {
  mkdir( $olson_temp );
}

if ( $^O ne "MSWin32" ) {
  $olson_dir = ".";
  $zic = osify("./zic");
}

sub run($) {
  my $cmd = shift;
  print "cmd: $cmd\n";
  system( $cmd );
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

if ( $stage1 ) {
chdir( $olson_temp ) or die "Can't change to dir $olson_temp $!\n";

my @files1 = <*.tar.gz>;

print join( " ", @files1 ) . "\n";

run( "wget 'ftp://elsie.nci.nih.gov/pub/tz*.tar.gz'" );

my @files2 = <*.tar.gz>;

#@files2 = qw/tzcode2010m.tar.gz tzdata2010m.tar.gz/;

#print @files2;

foreach ( @files2 ) {
  my $file = $_;
  if ( !grep(/$file/, @files1 ) ) {
    print "New file $file\n";
    if ( /tz....(.+)\.tar\.gz/ ) {
      $distro = $1;
      #mkdir( $dir );
      #run( "mv $file $dir/" );
      #chdir( $dir );
      run( "gzip -dc $file | tar -xf -" );
      #chdir( ".." );
    }
  }
}
}

if ( $distro ) {
  print "distro: $distro\n";
}
else {
  chdir( $olson_temp ) or die "Can't change to dir $olson_temp $!\n";

  my @tars = <$olson_temp/*.tar.gz>;

  foreach ( @tars ) {
    my $tar = $_;
    if ( /tzdata(.+)\.tar\.gz/ ) {
      $distro = $1;
      print "distro: $distro\n";
    }
  }
}

if ( $stage2 ) {
  chdir( $olson_temp );
  foreach ( <*> ) {
    run( "u2d --safe $_");
  }

  my $cmd = "cleartool catcs -tag $view";
  if ( open( CS, "$cmd |" ) ) {
    my ($h, $temp) = tempfile();
    #if ( open( OUT, ">$temp" ) ) {
      while ( <CS> ) {
        print ;
        if ( /element \* \// ) {
          print $h "element /topclass/oracle/topclass/sources/tz/... /main/olson/LATEST\n";
        }
        print $h $_;
      }
      close( $h );
    #}
    close( CS );
    run( "cleartool setcs -tag $view $temp" );
  }
  run( "ecopy -w -r -s $olson_temp -d $olson_dir -x *.bak" );
}

if ( $stage3 ) {
  chdir( $olson_dir );
  my $label = uc "tz$distro";
  run( "cleartool mklbtype -nc $label" );
  # check the all in.
  my $comment = "#00002 olson $distro";
  run( "for \%f in (*) do cleartool checkin -c \"$comment\" \%f" );

  run( "for \%f in (*) do cleartool mklabel $label \%f" );

  my $cmd = "cleartool catcs -tag $view";
  if ( open( CS, "$cmd |" ) ) {
    my ($h, $temp) = tempfile();
    #if ( open( OUT, ">$temp" ) ) {
      while ( <CS> ) {
        if ( m!/main/olson/LATEST! ) {
          print $h "# ";
        }
        print $h $_;
      }
      close( $h );
    #}
    close( CS );
    run( "cleartool setcs -tag $view $temp" );
  }
  run( "clearmrgman /branch olson /toview $view /namelist \\topclass\\oracle\\topclass\\sources\\tz" );
}

if ( $stage4 ) {
  # need to use cygwin
  if ( $^O eq "MSWin32" ) {
    print "ERROR: must run under cygwin not $^O\n";
  }
  chdir( "/cygdrive/w/topclass/oracle/topclass/sources/tz" );
  run( "cleartool co -nc zic.exe" );
  run( "make" );
}

if ( $stage5 ) {
  # need to use cygwin
  if ( $^O ne "MSWin32" ) {
    print "ERROR: must run under MSWin32 not $^O\n";
  }
$olson_dir = osify("$drive/topclass/oracle/topclass/sources/tz");

#run( "$vzic --olson-dir $olson_dir --pure --output-dir ./dir1" );

#run( "$vzic --olson-dir $olson_dir --output-dir ./dir2" );

chdir( $olson_dir );

 run( "./zic -s -d $distro -L leapseconds -y yearistype africa antarctica asia australasia backward etcetera europe northamerica southamerica" );

 my $zoneinfo = osify("$olson_dir/zoneinfo");

 # need to be using the olson/LATEST
 run( "ecopy -w -r -s $distro -d $zoneinfo -x *.bak" );

#run( "$zic -s -d ./dir3 -L $leapseconds africa" );

#run( "ecopy -w -r -s ./dir3 -d $drive\\topclass\\oracle\\topclass\\sources\\tz\\zoneinfo" );

#run( "cp zoneinfo/Africa/bamako zoneinfo/Africa/bamako.bin" );
#run( "cp dir3/Africa/bamako dir3/Africa/bamako.bin" );

#run( "textpad zoneinfo/Africa/bamako.bin dir3/Africa/bamako.bin" );
}

if ( $stage6 ) {
  chdir( "$drive/topclass/java/cnr/WebContent/WEB-INF/etc");

#whole lot
  run( "$vzic --olson-dir $olson_dir --pure --dump --output-dir $distro --product-id \"-//WBT Systems//NONSGML TopClass tz$distro//EN\" --tzid-prefix \"\"" );

  backwards($olson_dir, $distro);

# simple for outlook
  run( "$vzic --olson-dir $olson_dir --output-dir $distro-outlook --product-id \"-//WBT Systems//NONSGML TopClass tz$distro//EN\" --tzid-prefix \"\"" );

  backwards($olson_dir, "$distro-outlook");

  if ( 1 ) {
  run( "ecopy -w -n- -r -s $distro -d zoneinfo *.ics -x *.bak" );
  run( "ecopy -w -n- -r -s $distro-outlook -d zoneinfo-outlook *.ics -x *.bak" );

  run( "del $distro\\*.ics" );
  run( "del $distro-outlook\\*.ics" );

  }
}

sub backwards($$) {
  my ($olson_dir, $zoneinfo_dir) = @_;

  my $backward = osify( "$olson_dir/backward" );
  print "Processing $backward\n";
  if ( open( BACK, $backward ) ) {
    #print "Opened $backward\n";
    while ( <BACK> ) {
      chomp;
      s/\s+$//;
      if ( /Link\t+([^\t]+)\t+([^\t]+)/ ) {
        my $current = osify( "$zoneinfo_dir/$1.ics" );
        my $back = osify( "$zoneinfo_dir/$2.ics" );
        if ( -e $current ) {
          print "copy $current $back\n";
          copy( $current, $back );
        }
        else {
          if ( $current =~ /\\Etc\\/ ) {
            $current =~ s/\\Etc\\/\\/;
            if ( -e $current ) {
              print "copy $current $back\n";
              copy( $current, $back );
            }
          }
          print "Current file $current not found\n";
        }
      }
      elsif ( /^#/ ) {
      }
      elsif ( $_ ) {
        print "$_\n";
      }
    }
    close( BACK );
  }
  else {
    print "Failed to open $backward\n";
  }
}
