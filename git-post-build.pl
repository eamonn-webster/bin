#
# TODO should I be using a wbt branch
# so that I can keep my work separate.
#

use strict;
use File::Glob;
use Term::ReadKey;

my $ccdrive;
my $gitroot;
my $gitdrive;
my $gitletter;
my $MNP;
my $mnp;
my $view;

my $timestamp;

my $user = lc $ENV{USERNAME};

$ccdrive = "z:";
$ccdrive = $ARGV[1] if ( $ARGV[1] );

$gitdrive = "c:";

my @months  = qw/X JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC/;

my ($m, $n, $p, $b) = GetBuildNumber($ccdrive);
$view = viewFromDrive($ccdrive);
$mnp = "$m$n$p";

my $gitbranch = "master";
$gitbranch = "${mnp}_branch" if ( $mnp ne "810" );

#$view = "eweb_prism"; # user_host or subst for z: drive


$gitroot = "$gitdrive\\cpp\\tc${mnp}";
my $build = $ARGV[0];

#$mnp = $ARGV[2] if ( $ARGV[2] );
#$view = $ARGV[3] if ( $ARGV[3] );

if ( $mnp =~ /([0-9])([0-9])([0-9])/ ) {
  $MNP = "$1.$2.$3";
}

$gitbranch = "${mnp}_branch" unless ( $mnp eq 810 );

my $prevodd = sprintf( "%03d", $build-1 );
my $nextodd = sprintf( "%03d", $build+1 );
$build = sprintf( "%03d", $build );
if ( $gitdrive =~ /^(.):/ ) {
  $gitletter = $1;
}

# TODO check git branch and clearcase view for build and version numbers...

#my $pattern = "\\\\wendy\\d\$\\autodevbuild\\buildlogs\\TopClassV$MNP\\build$build\\blog*.txt";
#print "pattern: $pattern\n";

#$pattern =~ s!\\!/!g;

#my @files = File::Glob::bsd_glob( $pattern );

#print "files: @files\n";

#exit;

ChDir( "$gitroot" );

my @Commands = (
  "checkGitBranch ${user}_${mnp}_work_${prevodd}",
  "cleartool lspriv -tag $view",
  "delall $ccdrive",
  "dir \\\\wendy\\d\$\\autodevbuild\\buildlogs\\TopClassV$MNP\\build$build\\blog*.txt",
  "REM >>>>>> add -time to all LATEST rules.",
  "addTimeToLatest",
  "cleartool edcs -tag $view",
  "checkBuildNo $m $n $p $prevodd",
  "cc2drive tc$mnp $gitdrive $ccdrive -Y *",
  "REM a chance to delete files",
  "drive2cc tc$mnp $gitdrive $ccdrive",
  "git add -n -u .",
  "git add -u .",
  "git add -n .",
  "git add .",
  "getcomments.pl",
  "git commit -F c:\\temp\\$gitletter-comments.bat",
  "git checkout $gitbranch",
  "git merge ${user}_${mnp}_work_${prevodd}",
  "REM >>>>>> comment out -time rules.",
  "REM >>>>>> element * TC_${mnp}_BUILD_${build}",
  "removeTimeFromLatestAndAddLabel",
  "cleartool edcs -tag $view",
  "cc2drive tc${mnp} $gitdrive $ccdrive -Y *",
  "git add -n -u .",
  "git add -u .",
  "git add -n .",
  "git add .",
  "git commit -m \"#00001 ${MNP}.${build}\"",
  "git tag TC_${mnp}_BUILD_${build}",
  "git checkout -b ${user}_${mnp}_work_${nextodd}",
  "REM >>>>>> comment out label rule TC_${mnp}_BUILD_${build}",
  "cleartool edcs -tag $view",
  "cc2drive tc${mnp} $gitdrive $ccdrive",
  "git add -u -n .",
  "git add -u .",
  "git add -n .",
  "git add .",
  "git commit -m \"#00001 ${MNP}.${nextodd}\"",
  "getcomments.pl",
  "git commit -F c:\\temp\\$gitletter-comments.bat",
  "git push --all",
  "git push --tags",
);

my $step = 0;

my $count = 0;
while ( $count < 100 ) {
  print "$step: $Commands[$step]\n";
  ReadMode 'cbreak';
  my $ch = ReadKey(0);
  ReadMode 'normal';
  #print "[$ch]\n";
  if ( $ch eq "n" ) {
    $step++;
  }
  elsif ( $ch eq "p" ) {
    $step--;
  }
  elsif ( $ch eq "q" ) {
    last;
  }
  elsif ( $ch eq "x" ) {
    runCmd( $Commands[$step], 1 );
  }
  $count++;
  #print "\$step: $step gt \$#Commands $#Commands\n";
  if ( $step > $#Commands ) {
    $step--;
  }
  elsif ( $step lt 0 ) {
    $step = 0;
  }
}

if ( 0 ) {
#1) add -time rule to config spec. All LATEST rules.
#ChDir( "$ccdrive\\" );
print ">>>>>> add -time to all LATEST rules.\n";
runCmd( "cleartool edcs -tag $view" );
# could get the time from buildno.h or from the build log
#if ( open( CS< "cleartool catcs |") ) {
#  while ( <CS> ) {
#    #add a time clause after LATEST...
#  }
#  close( CS );
#}
#2) cc2drive tc810 c: z: # use release view
runCmd( "cc2drive tc$mnp $gitdrive $ccdrive -Y *" );
#3) git add
ChDir( "$gitroot" );
runCmd( "git add -n ." );
#4) getcomments
runCmd( "getcomments.pl" );
#5) git commit
runCmd( "git commit -F c:\\temp\\$gitletter-comments.bat" );
#6) git checkout $gitbranch
runCmd( "git checkout $gitbranch" );
#7) git merge eweb_810_work_055
runCmd( "git merge ${user}_${mnp}_work_${prevodd}" );
#8) change config spec to label (at the top)
#ChDir( "$ccdrive\\" );
print ">>>>>> comment out -time rules.\n";
print ">>>>>> element * TC_${mnp}_BUILD_${build}\n";
runCmd( "cleartool edcs -tag $view" );
#9) cc2drive tc810 c: z: # use release view
runCmd( "cc2drive tc${mnp} $gitdrive $ccdrive -Y *" );
#10) git commit -m "#00001 8.1.0.056"
#ChDir( "$gitroot" );
runCmd( "git add -n -u ." );
runCmd( "git commit -m \"#00001 ${MNP}.${build}\"" );
#11) git tag TC_810_BUILD_064
runCmd( "git tag TC_${mnp}_BUILD_${build}" );
#12) git checkout -b eweb_810_work_057
runCmd( "git checkout -b ${user}_${mnp}_work_${nextodd}" );
#13) remove label from config spec
#ChDir( "$ccdrive\\" );
print ">>>>>> comment out label rule TC_${mnp}_BUILD_${build}\n";
runCmd( "cleartool edcs -tag $view" );
#14) cc2drive tc810 c: z: # use release view
runCmd( "cc2drive tc${mnp} $gitdrive $ccdrive" );
#15) git add
#ChDir( "$gitroot" );
runCmd( "git add -u -n ." );
#16) git commit -m "#00001 8.1.0.057" and any other quick fixes.
runCmd( "git commit -m \"#00001 ${MNP}.${nextodd}\"" );
# or if otherthings have changed...
runCmd( "getcomments.pl" );
#5) git commit
runCmd( "git commit -F c:\\temp\\$gitletter-comments.bat" );
#17) git push --all
runCmd( "git push --all" );
#18) git push --tags
runCmd( "git push --tags" );
}

sub runCmd($$) {
  my ($cmd,$really) = @_;
  print "$cmd\n";
  if ( $really ) {
    if ( $cmd =~ /^dir (.+)/ ) {
      my $pattern = $1;
      #print "pattern: $pattern\n";
      $pattern =~ s!\\!/!g;
      #print "pattern: $pattern\n";

      my @files = File::Glob::bsd_glob( $pattern );
      $timestamp = undef;
      foreach ( @files ) {
        s!.+/!!g;
        if ( /blog-([0-9]{4})-([0-9]{2})-([0-9]{2})-([0-9]{2})([0-9]{2})-.*\.txt/ ) {
          my ($y, $m, $d, $h, $mi) = ($1, $2, $3, $4, $5);
          $m = $months[$m];
          $timestamp = "$d-$m-$y.$h:$mi" unless ( $timestamp );

          print "  $_ ($timestamp) \n";
        }
        else {
          print "  $_\n";
        }
      }
    }
    elsif ( $cmd =~ /^REM/ ) {
    }
    elsif ( $cmd eq "addTimeToLatest" ) {
      addTimeToLatest();
    }
    elsif ( $cmd eq "removeTimeFromLatestAndAddLabel" ) {
      removeTimeFromLatestAndAddLabel();
    }
    elsif ( $cmd eq "removeLabel" ) {
      removeLabel();
    }
    elsif ( $cmd =~ /checkBuildNo ([0-9]+) ([0-9]+) ([0-9]+) ([0-9]+)/ ) {
      my @shouldBe = ($1, $2, $3, $4);
      my @found = GetBuildNumber( $ccdrive );
      if ( "@shouldBe" eq "@found" ) {
        print "Version and build okay (@shouldBe eq @found)\n";
      }
      else {
        print "ERROR: Version and build should be @shouldBe but found @found\n";
      }
    }
    elsif ( $cmd =~ /checkGitBranch (.+)/ ) {
      my $shouldBe = $1;
      my $found;
      if ( open( CMD, "git branch |" ) ) {
        while ( <CMD> ) {
          chomp;
          if ( /^\* (.+)/ ) {
            $found = $1;
          }
        }
        close( CMD );
      }
      if ( $shouldBe eq $found ) {
        print "git branch is okay\n";
      }
      else {
        print "git branch should be $shouldBe but found $found\n";
      }
    }
    elsif ( open( CMD, "$cmd |" ) ) {
      while ( <CMD> ) {
        print;
      }
      close( CMD );
    }
  }
}

sub ChDir($) {
  my ($dir) = @_;
  print "chdir /d $dir\n";
  chdir( $dir );
}

sub GetBuildNumber( $ ) {
  my ($drive) = @_;

  my $BuildNoFile = "$drive/topclass/oracle/topclass/sources/buildno.h";
  if ( -e $BuildNoFile ) {
      print "Found $BuildNoFile\n";
  }
  else {
      print "Couldn't find $BuildNoFile\n";
      my $VersionInfoFile = "$drive/topclass/oracle/topclass/sources/versioninfo.h";
      if ( -e $VersionInfoFile ) {
          print "Found $VersionInfoFile\n";
          $BuildNoFile = $VersionInfoFile;
      }
      else {
          print "Couldn't find $VersionInfoFile\n";
          my $NeoBuildNoFile = "$drive/topclass/neo/sources/buildno.h";
          if ( -e $NeoBuildNoFile ) {
              print "Found $NeoBuildNoFile\n";
              $BuildNoFile = $NeoBuildNoFile;
          }
          else {
              print "Couldn't find $NeoBuildNoFile\n";
              my $VersionInfoFile = "$drive/topclass/neo/sources/versioninfo.h";
              if ( -e $VersionInfoFile ) {
                  print "Found $VersionInfoFile\n";
                  $BuildNoFile = $VersionInfoFile;
              }
              else {
                  print "Couldn't find $VersionInfoFile\n";
              }
          }
      }
  }

  #print "$BuildNoFile\n";

  if ( !open (BUILDNO, $BuildNoFile) ) {
      print "Couldn't open '$BuildNoFile' $!\n";
      return;
  }

  my ($Major, $Minor, $Point, $Build);
  while ( <BUILDNO> ) {
      if ( /\#define BUILDNUMBER +([0-9]+)/ ) {
          $Build = $1;
          #$Build++;
          #$Build--;
      }
      elsif ( /\#define MAJORREVISION +([0-9]+)/ ) {
          $Major = $1;
      }
      elsif ( /\#define MINORREVISION +([0-9]+)/ ) {
          $Minor = $1;
      }
      elsif ( /\#define POINTREVISION +([0-9]+)/ ) {
          $Point = $1;
      }
  }
  close BUILDNO;
  $Build = sprintf( "%03d", $Build );
  print "$Major, $Minor, $Point, $Build\n";
  return ($Major, $Minor, $Point, $Build);
}

sub viewFromDrive($) {
  my ($drive) = @_;
  #print "viewFromDrive($drive)\n";
  if ( open( SUBST, "subst |") ) {
    while ( <SUBST> ) {
      if ( /(.:)\\: => .:\\(.+)/ ) {
        #print "$1 $2\n";
        if ( lc $1 eq lc $drive ) {
          #print "drive $1 is view $2\n";
          return $2;
        }
      }
    }
  }
}
#element * /main/LATEST #-time 20-JAN-2011.19:59

sub addTimeToLatest() {
  if ( open( CS, "cleartool catcs -tag $view |") ) {
    while ( <CS> ) {
      #my $save = $_;
      if ( /[^#]+LATEST/ ) {
        if ( /-time/ ) {
          s!-time.+!!;
        }
        s!LATEST!LATEST -time $timestamp!;
      }
      print;
    }
  }
}

sub removeTimeFromLatestAndAddLabel() {
  if ( open( CS, "cleartool catcs -tag $view |") ) {
    print "element * TC_${mnp}_BUILD_${build}\n";
    while ( <CS> ) {
      #my $save = $_;
      if ( /[^#]+LATEST/ ) {
        s!LATEST -time $timestamp!LATEST!;
      }
      print;
    }
  }
}

sub removeLabel() {
  if ( open( CS, "cleartool catcs -tag $view |") ) {
    while ( <CS> ) {
      #my $save = $_;
      unless ( /element \* TC_${mnp}_BUILD_${build}/ ) {
        print;
      }
    }
  }
}
