#!/usr/bin/perl
use strict;
use Cwd;

my $curDir =  getcwd();

my $root;
if ( $curDir =~ /^(.):/ ) {
  $root = "$1:";
}
elsif ( $curDir =~ /^\/cygdrive\/(.)/ ) {
  $root = "/cygdrive/$1";
}
elsif ( $^O eq "darwin" ) {
  $root = ".";
}
elsif ( $curDir =~ /^\/(.)/ ) {
  $root = "/$1";
}

print "curDir: $curDir\n";

my $prefix = "tc";
my $mnp;
if ( open(BUILDNO, "$root/topclass/oracle/topclass/sources/buildno.h") ) {
  while ( <BUILDNO> ) {
    if ( /#define THREEDIGITVER _TEXT\("([0-9]+)"\)/ ) {
      $mnp = $1;
      last;
    }
  }
  close(BUILDNO);
}
elsif ( open(BUILDNO, "$root/java/acc/src/org/eweb/cpp/AppInfo.java") ) {
  $prefix = "wacc";
  my ($m, $n, $p, $b);
  while ( <BUILDNO> ) {
    if ( /public static final int MAJOR = ([0-9]+);/ ) {
      $m = $1;
    }
    if ( /public static final int MINOR = ([0-9]+);/ ) {
      $n = $1;
    }
    if ( /public static final int POINT = ([0-9]+);/ ) {
      $p = $1;
    }
    if ( /public static final int BUILD = ([0-9]+);/ ) {
      $b = $1;
    }
  }
  $mnp = "$m$n$p";
  close(BUILDNO);
}

#print "$mnp\n";

if ( open(BRANCHES, "git branch |") ) {
  while ( <BRANCHES> ) {
    #eweb_900_work_b27
    if ( /^\*/ ) {
      if ( /eweb_([0-9]+)_work/ ) {
        if ( $mnp eq "" ) {
          $mnp = $1;
        }
        elsif ( $1 ne $mnp ) {
          print "Branch name $1 doesn't match buildno $mnp\n";
        }
        else { #if ( $1 eq $mnp ) {
          #print "Branch name $1 matches buildno $mnp\n";
        }
      }
    }
  }
  close(BRANCHES);
}
if ( $mnp eq "" ) {
  $mnp = "800"
}

print "mnp: $mnp\n";

my $backups = "/cygdrive/c/backups/";
if ( $^O eq "darwin" ) {
  $backups = $ENV{HOME} . "/backups/";
}

my ($sec, $min, $hour, $day, $mon, $year) = localtime(time);

my $date = sprintf( "%04d-%02d-%02d", ($year + 1900), ($mon + 1), $day );

my $cmd = "tar -czvf ${backups}${prefix}${mnp}-git-${date}.tar.gz $root/.git";
print "cmd: $cmd\n";
system( $cmd );
