use strict;

my $mnp = $ARGV[0];
my $build = $ARGV[1];

if ( $mnp eq "" or $build eq "" ) {
  die "usage: $0 mnp build\n";
}

if ( $mnp !~ /^[0-9][0-9][0-9]$/ or $build !~ /^[0-9]+$/ ) {
  die "usage: $0 mnp build\n";
}

my ($m, $n, $p) = ( $mnp =~ /([0-9])([0-9])([0-9])/ );

$build = sprintf( "%03d", $build );

my $debug;

$| = 1; # immediate flushing

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

sub runCmd($;$) {
  my ($cmd, $where) = @_;
  $where = 0 if ( $where eq "" );

  print "$cmd\n" unless ( $where & 1 );
  #if ( $BuildLog ) {
  #  print $BuildLog encode_entities($cmd) . "\n" unless ( $where & 2 );
  #}
  my $h;
  if ( open( $h, "$cmd 2>&1 |" ) ) {
    while ( <$h> ) {
      print unless ( $where & 1 );
      #if ( $BuildLog ) {
      #  print $BuildLog encode_entities($_) unless ( $where & 2 );
      #}
    }
    close( $h );
  }
}

sub Unzip($$) {
  my ($source, $dest) = @_;

  my $cmd = "unzip -o $source -d $dest";

  #runCmd($cmd);

  my $where = 0;

  print "$cmd\n" unless ( $where & 1 );
  #if ( $BuildLog ) {
  #  print $BuildLog encode_entities($cmd) . "\n" unless ( $where & 2 );
  #}
  my $h;
  if ( open( $h, "$cmd 2>&1 |" ) ) {
    while ( <$h> ) {
      if ( /^  inflating:/ or /^   creating:/ or /^ extracting:/ ) {
      }
      else {
        print unless ( $where & 1 );
      }
      #if ( $BuildLog ) {
      #  print $BuildLog encode_entities($_) unless ( $where & 2 );
      #}
    }
    close( $h );
  }
}

sub CopyFile( $$;$ ) {
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
    $dst = "$dst/"   if ( $flags =~ /i/ ); # /i  dest is a folder
    $cmd = "cp $flags \"$src\" \"$dst\"";
  }
  runCmd($cmd);
}

sub RmDir( $ ) {
  my ($dir) = @_;
  if ( -d $dir ) {
    my $cmd = "rd /s /q \"$dir\"";
    print "$cmd\n";
    system( $cmd );
  }
}

sub DeleteFile( $ ) {
  my ($file) = @_;
  $file = osify($file);
  if ( $file =~ /\*/ ) {
    if ( glob( $file ) ) {
      my $cmd = "del /f \"$file\"";
      print "$cmd\n";
      system( $cmd );
    }
    else {
      print "glob( $file ) => nil\n" if ( $debug );
    }
  }
  elsif ( -e $file ) {
    my $cmd = "del /f \"$file\"";
    print "$cmd\n";
    system( $cmd );
  }
  else {
    print "! -e $file\n" if ( $debug );
  }
}

sub DeleteFiles( $ ) {
  my ($files) = @_;
  if ( $files =~ /\*/ ) {
    my $cmd = "del /s /f $files";
    print "$cmd\n";
    system( $cmd );
  }
  elsif ( -e $files ) {
    my $cmd = "del /s /f \"$files\"";
    print "$cmd\n";
    system( $cmd );
  }
}

CopyFile( "//prism/c\$/cpp/tc${mnp}b${build}.zip", "c:/drop", "d" );

my $dist = "c:/temp/tc${mnp}b${build}";

my $dest = "c:/cpp/tc${mnp}";

RmDir( $dist );

Unzip( "c:/drop/tc${mnp}b${build}.zip", $dist );


DeleteFile( "$dist/authoring/assistant/tcmetadatamod/metadllmod.aps" );

DeleteFile( "$dist/authoring/assistant/tcmetadatamod/Languages/tcmetadatamodlang/tcmetadatamodlang.clw" );

DeleteFile( "$dist/authoring/utilities/Scorm2Plug/Sample/Project1.exe" );

DeleteFile( "$dist/authoring/utilities/tccomverter/comexamples/vbtest/vbtest.exe" );

#"$dist/authoring/utilities/TCServerDacPrj/TCServerDacMod/dlldatax.c"

RmDir( "$dist/authoring/utilities/tcdoccom/doc" );

DeleteFile( "$dist/topclass/oracle/topclass/Neo/NeoTypes*.pch" );

RmDir( "$dist/topclass/oracle/topclass/Scripts/MSSQL/Upgrade/Incremental/Diffs" );

DeleteFile( "$dist/topclass/oracle/topclass/Scripts/Tools/ORACLE/PerfStat/Descript.ion" );
DeleteFile( "$dist/topclass/oracle/topclass/Scripts/Tools/ORACLE/PerfStat/Documentation/PerfMon.doc" );
DeleteFile( "$dist/topclass/oracle/topclass/Scripts/Tools/ORACLE/PerfStat/ExpImp/EXPORT/Tc_PerfMon_exp.par" );
DeleteFile( "$dist/topclass/oracle/topclass/Scripts/Tools/ORACLE/PerfStat/ExpImp/IMPORT/Tc_PerfMon_Imp.par" );
DeleteFile( "$dist/topclass/oracle/topclass/Scripts/Tools/SchemaDiff/MSSQL/Descript.ion" );
DeleteFile( "$dist/topclass/oracle/topclass/Scripts/Tools/SchemaDiff/MSSQL/SchemaViews/ModelConfig.cfg" );
DeleteFile( "$dist/topclass/oracle/topclass/Scripts/Tools/SchemaDiff/MSSQL/TopClass_Model/SQL/Descript.ion" );
DeleteFile( "$dist/topclass/oracle/topclass/Scripts/Tools/SchemaDiff/MSSQL/Utils/Descript.ion" );
DeleteFile( "$dist/topclass/oracle/topclass/Scripts/Tools/SchemaDiff/ORACLE/scripts/ToDos.lst" );
DeleteFile( "$dist/topclass/oracle/topclass/sources/questions/booleanWithReason/boolWithReasonstrings.r" );
DeleteFile( "$dist/utils/AutoDevBuild/TopClassAutomatedBuildProcedure.doc" );


DeleteFile( "$dist/utils/lfa/TclLibraries" );

RmDir( "$dist/utils/lfa/install" );

#W:\topclass\oracle\topclass\www\dat\zoneinfo
#w:\topclass\oracle\topclass\sources\tz\zoneinfo

#junction w:\topclass\oracle\topclass\sources\tz\zoneinfo W:\topclass\oracle\topclass\www\dat\zoneinfo

my $ecopy = "ecopy -w -r -n- -s $dist -d $dest -x *.bak -x *.diff";
print "cmd: $ecopy\n";
system( $ecopy );
$ecopy = "ecopy -w -r -n- -d $dist -d $dest -x *.bak -x *.diff -x .git -x .gitignore";
print "cmd: $ecopy\n";

my $prevno = $build-1;
my $nextno = $build+1;

my @cmds = (
  "incbuildno.pl $dest " . sprintf( "%d", $prevno ),
  "git add --update",
  "git status",
  "git commit --file=" . osify("c:/changes/Version${mnp}/Changes_in_${mnp}_build_${build}.txt"),
  "git checkout master / 800_branch",
  "git merge --no-commit --no-ff --log eweb_${mnp}_work_" . sprintf( "%03d", $prevno ),
  "git commit",
  "incbuildno.pl $dest " . sprintf( "%d", $build ),
  "git add --update",
  "git commit -m \"#00001 $m.$n.$p.$build\"",
  "git tag TC_${mnp}_BUILD_${build}",
  "git checkout -b eweb_${mnp}_work_" . sprintf( "%03d", $nextno ),
  "incbuildno.pl $dest " . sprintf( "%d", $nextno ),
  "rmdir /s /q $dist"
 );

foreach ( @cmds ) {
  print "$_\n";
}
