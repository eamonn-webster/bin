#
# File: copy4msi.pl
# Author: eweb
# Copyright WBT Systems, 1995-2010
# Contents:
#
# Date:          Author:  Comments:
# 30th Jun 2009  eweb     #00008 prep for msi installer
#  3rd Jul 2009  eweb     #00008 Updated instructions
# 31st Aug 2009  eweb     #11870 Updated instructions
#  9th Sep 2009  eweb     #11202 Instructions to execute vcredist_x86.exe
# 17th Sep 2009  eweb     #11202 Instructions to include merge module for rt dlls
#  1st Oct 2009  eweb     #00008 Runable
#  7th Oct 2009  eweb     #00008 Make it Runable
#  2nd Nov 2009  eweb     #12055 register msxml4.dll
# 10th Nov 2009  bob      #00008 perl script to update .msifact
# 19th Nov 2009  eweb     #00008 vars
# 29th Jan 2010  eweb     #00008 copy oracle & sql server scripts, service, but not the installers.
# 27th Apr 2010  eweb     #00008 Must first clear out the directory
# 11th Nov 2010  eweb     #00008 Converted copy4msi.bat to copy4msi.pl
# 30th Nov 2010  eweb     #00008 Option to copyfiles or not
#

use strict;

my $major = $ARGV[0];
my $minor = $ARGV[1];
my $point = $ARGV[2];
my $build = $ARGV[3];
my $drive = $ARGV[4];
my $CopyFiles = $ARGV[5];
my $useHeat;

sub Usage() {
  print "perl $0 major minor point build drive copyFiles\n";
}

my $heat = "\"c:\\Program Files\\Windows Installer XML v3\\bin\\heat.exe\"";
# set build=082

my $neon_builds = "\\\\radon\\builds";

$neon_builds = "c:\\builds" if ( lc $ENV{COMPUTERNAME} eq "floyd" );
$drive  = "c:" if ( lc $ENV{COMPUTERNAME} eq "floyd" );
$drive  = "c:" if ( lc $ENV{COMPUTERNAME} eq "prism" );
$drive  = "d:" if ( lc $ENV{COMPUTERNAME} eq "wendy" );

if ( !$build ) {
  Usage();
  die "echo ERROR: must specify a build three digits please\n";
}

if ( $CopyFiles ne "N" ) {
  RmDir( "${drive}\\Installer_Files\\build${build}" );
}

if ( ! -d "${drive}\\Installer_Files\\build${build}" ) {
  $CopyFiles = "Y";
}

if ( $CopyFiles ne "N" ) {
  XCopy( "${neon_builds}\\TopClassV${major}.${minor}.${point}\\builds\\build${build}\\windows\\nonwebable", "${drive}\\Installer_Files\\build${build}\\TopClass Server", "sid" );
  XCopy( "${neon_builds}\\TopClassV${major}.${minor}.${point}\\builds\\build${build}\\windows\\webable", "${drive}\\Installer_Files\\build${build}\\topclass", "sid" );
  XCopy( "${neon_builds}\\TopClassV${major}.${minor}.${point}\\builds\\build${build}\\CrystalReports", "${drive}\\Installer_Files\\build${build}\\topclass\\CrystalReports", "sid" );

  if ( -d "${drive}\\Installer_Files\\build${build}\\TopClass Server\\tcc" ) {
    MoveFile( "${drive}\\Installer_Files\\build${build}\\TopClass Server\\tcc", "${drive}\\Installer_Files\\build${build}\\tcc" );
  }
  else {
    XCopy( "${neon_builds}\\TopClassV${major}.${minor}.${point}\\builds\\build${build}\\windows\\tcc", "${drive}\\Installer_Files\\build${build}\\tcc", "sid" );
  }

  # tomcat uses java which needs msvcr71.dll
  CopyFile( "${drive}\\Installer_Files\\build${build}\\tcc\\jdk\\bin\\msvcr71.dll", "${drive}\\Installer_Files\\build${build}\\tcc\\tomcat\\bin\\msvcr71.dll" );

  MoveFile( "${drive}\\Installer_Files\\build${build}\\tcc\\catandregwar\\cnr.war", "${drive}\\Installer_Files\\build${build}\\tcc\\tomcat\\webapps\\cnr.war" );
  RmDir( "${drive}\\Installer_Files\\build${build}\\tcc\\catandregwar" );

  MoveFile( "${drive}\\Installer_Files\\build${build}\\topclass\\CrystalReports", "${drive}\\Installer_Files\\build${build}\\topclass\\Reports" );

  MoveFile( "${drive}\\Installer_Files\\build${build}\\topclass\\Reports\\cr_report.exe", "${drive}\\Installer_Files\\build${build}\\TopClass Server\\cpi\\" );

  MkDir( "${drive}\\Installer_Files\\build${build}\\TopClass Server\\reports" );

  MoveFile( "${drive}\\Installer_Files\\build${build}\\topclass\\Reports\\cruflwbt.dll", "${drive}\\Installer_Files\\build${build}\\TopClass Server\\reports\\" );

  MkDir( "${drive}\\Installer_Files\\build${build}\\TopClass Server\\service" );

  # copying service executable and stub
  CopyFile( "${neon_builds}\\TopClassV${major}.${minor}.${point}\\builds\\build${build}\\windows\\service\\topclassd.exe", "${drive}\\Installer_Files\\build${build}\\TopClass Server\\service" );
  CopyFile( "${neon_builds}\\TopClassV${major}.${minor}.${point}\\builds\\build${build}\\windows\\tce${major}${minor}${point}iis.dll", "${drive}\\Installer_Files\\build${build}\\TopClass Server\\service" );

  # copying oracle and sql server scripts
  XCopy( "${neon_builds}\\TopClassV${major}.${minor}.${point}\\builds\\build${build}\\Oracle", "${drive}\\Installer_Files\\build${build}\\TopClass Server\\Oracle", "sid" );
  XCopy( "${neon_builds}\\TopClassV${major}.${minor}.${point}\\builds\\build${build}\\MSSQL", "${drive}\\Installer_Files\\build${build}\\TopClass Server\\MSSQL", "sid" );

  #CopyFile( "${neon_builds}\\TopClassV${major}.${minor}.${point}\\builds\\build${build}\\TCDB${major}${minor}${point}MSSQLb${build}.exe", "${drive}\\Installer_Files\\build${build}\\" );
  #CopyFile( "${neon_builds}\\TopClassV${major}.${minor}.${point}\\builds\\build${build}\\TCDB${major}${minor}${point}Oracleb${build}.exe", "${drive}\\Installer_Files\\build${build}\\" );

  CopyFile( "${drive}\\Installer_Files\\vcredist_x86.exe", "${drive}\\Installer_Files\\build${build}\\" );

  # delete the release notes, as they are not yet fit for release.
  unlink( "${drive}\\Installer_Files\\build${build}\\TopClass Server\\documentation\\TopClass${major}${minor}${point}_release_notes.doc" );
}

if ( $useHeat ) {
  runCmd( "$heat dir \"build${build}\\TopClass Server\" -sw5150 -ag -out build${build}\\nonwebable.xxx" );
  runCmd( "$heat dir \"build${build}\\topclass\" -sw5150 -ag -out build${build}\\webable.xxx" );
  runCmd( "$heat dir \"build${build}\\tcc\" -sw5150 -ag -out build${build}\\tcc.xxx" );
}

# update build number in the .msifact file
system( "perl \\utils\\AutoDevBuild\\bin\\updatemsi.pl ${drive} ${major} ${minor} ${point} ${build}" );

print "start msifactory and\n";
print "open \"${drive}\\Installer_Files\\topclass8_installer.msifact\"\n";

print "remove all files\n";
print "select all and delete\n";
print "click add files\n";
print "browse to \"${drive}\\Installer_Files\\build${build}\"\n";
print "click all files in folder and their contents\n";

print "Add a shortcut to TC800Install.doc  TopClass 8 Installation Guide\n";

print "setup components to register\n";
print "for topclassdb.dll, CRUFLwbt.dll and msxml4.dll\n";
print "right click ... File Properties ... Registration Tab\n";
print "under COM/ActiveX Registration choose Self Register\n";
print "Okay\n";

print "should be there but\n";
print "Add merge module for the visual c++ run time.\n";
print "Add ${drive}\\Installer_Files\\Microsoft_VC80_CRT_x86.msm\n";
print "it should pick up the policy file from the same directory.\n";


print "click Build Installer\n";

print "If it worked close it\n";

runCmd( "\"C:\\Program Files\\MSI Factory\\MSI Factory.exe\" \"${drive}\\Installer_Files\\topclass8_installer.msifact\"" );

runCmd( "pause" );

CopyFile( "${drive}\\Installer_Files\\Output\\TC${major}${minor}${point}b${build}.msi", "${neon_builds}\\TopClassV${major}.${minor}.${point}\\builds\\build${build}\\" );

# backup ...

CopyFile( "${drive}\\Installer_Files\\topclass8_installer.msifact", "${drive}\\Installer_Files\\TC${major}${minor}${point}b${build}.msifact" );

my $BuildLog;

sub XCopy( $$;$ ) {
  my ($src, $dst, $flags) = @_;

  $src = osify($src);
  $dst = osify($dst);

  my $cmd;
  if ( $^O eq "MSWin32" ) {
    $flags =~ s!(.)!/$1 !g;

    $cmd = "xcopy $flags \"$src\" \"$dst\"";
  }
  else {
    # flags siyd
    $cmd = "cp";
    $cmd = "$cmd -R" if ( $flags =~ /s/ ); # /s -R recursive
    $cmd = "$cmd -u" if ( $flags =~ /d/ ); # /d -u update
    $cmd = "$cmd -f" if ( $flags =~ /y/ ); # /y -f force
    $dst = "$dst/" if ( $flags =~ /i/ && $dst !~ m!/$! ); # /i -f force
    $cmd = "$cmd $src $dst";
  }
  runCmd($cmd);
}

sub CopyFile( $$;$ ) {
  my ($src, $dst, $flags) = @_;

  $src = osify($src);
  $dst = osify($dst);
  my $cmd;
  if ( $^O eq "MSWin32" ) {
    $flags =~ s!(.)!/$1 !g;

    $cmd = "copy $flags \"$src\" \"$dst\"";
  }
  else {
    # flags siyd
    $cmd = "cp";
    $cmd = "$cmd -R" if ( $flags =~ /s/ ); # /s -R recursive
    $cmd = "$cmd -u" if ( $flags =~ /d/ ); # /d -u update
    $cmd = "$cmd -f" if ( $flags =~ /y/ ); # /y -f force
    $dst = "$dst/" if ( $flags =~ /i/ ); # /i -f force
    $cmd = "cp $flags \"$src\" \"$dst\"";
  }
  runCmd($cmd);
}

sub MoveFile( $$;$ ) {
  my ($src, $dst, $flags) = @_;

  $src = osify($src);
  $dst = osify($dst);
  my $cmd;
  if ( $^O eq "MSWin32" ) {
    $flags =~ s!(.)!/$1 !g;

    $cmd = "move $flags \"$src\" \"$dst\"";
  }
  else {
    # flags siyd
    $cmd = "mv";
    $cmd = "$cmd -R" if ( $flags =~ /s/ ); # /s -R recursive
    $cmd = "$cmd -u" if ( $flags =~ /d/ ); # /d -u update
    $cmd = "$cmd -f" if ( $flags =~ /y/ ); # /y -f force
    $dst = "$dst/" if ( $flags =~ /i/ ); # /i -f force
    $cmd = "cp $flags \"$src\" \"$dst\"";
  }
  runCmd($cmd);
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
my $BuildLog;

sub runCmd($;$) {
  my ($cmd, $where) = @_;
  $where = 0 if ( $where eq "" );

  print "$cmd\n" unless ( $where & 1 );
  if ( $BuildLog ) {
    print $BuildLog encode_entities($cmd) . "\n" unless ( $where & 2 );
  }
  my $h;
  if ( open( $h, "$cmd 2>&1 |" ) ) {
    while ( <$h> ) {
      print unless ( $where & 1 );
      if ( $BuildLog ) {
        print $BuildLog encode_entities($_) unless ( $where & 2 );
      }
    }
    close( $h );
  }
}

sub RmDir($) {
  my ($dir) = @_;
  $dir = osify($dir);

  if ( ! -d $dir ) {
    print $BuildLog "RmDir $dir does not exist<br/>\n";
  }

  my $cmd;
  if ( $^O eq "MSWin32" ) {
    $cmd = "rmdir /s /q \"$dir\""
  }
  else {
    $cmd = "rm -Rf \"$dir\""
  }

  if ( $BuildLog ) {
    print $BuildLog "$cmd<br/>\n";
  }
  open( CMD, "$cmd 2>&1 |");

  while ( <CMD> ) {
    chomp;
    if ( $BuildLog ) {
      print $BuildLog $_ . "<br/>\n";
    }
  }
  #system( "rmdir /s /q $dir" );
  #elsif ( rmdir( $dir ) ) {
  #  print COPYLOG "RmDir $dir\n";
  #}
  #else {
  #  print COPYLOG "RmDir $dir FAILED $!\n";
  #}
}

sub MkDir($) {
  my ($dir) = @_;
  if ( -d $dir ) {
    print "MkDir $dir exists\n";
  }
  else {
    my $sofar = "";
    foreach ( split( /\\/, $dir ) ) {
      #print "[$_]\n";
      if ( $sofar eq "" ) {
        if ( $_ ne "" and $dir =~ /^\\\\/ ) {
          $sofar = "\\\\$_";
        }
        else {
          $sofar = $_;
        }
      }
      else {
        $sofar = "$sofar\\$_";
        if ( -d $sofar ) {
          #print COPYLOG "MkDir $sofar exists\n";
        }
        elsif ( mkdir( $sofar ) ) {
          #print COPYLOG "MkDir $dir\n";
        }
        else {
          LogError( "MkDir $sofar FAILED! $!" );
          return 0;
        }
      }
    }
    #print COPYLOG "MkDir $dir\n";
  }
}


