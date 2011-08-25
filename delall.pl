#
# File: delall.pl
# Author: eweb
# Copyright WBT Systems, 1995-2011
# Contents: Deletes temporary files from all vobs
#
# Date:          Author:  Comments:
# 10th May 2007  eweb     #00008 use fork because we don't want to wait for textpad to exit.
# 31st May 2010  eweb     #00008 Delete 'all' temporary files
# 10th Jun 2010  eweb     #00008 Delete vb.net and lisp temps.
# 24th Jun 2010  eweb     #00008 rmdir /topclass/java/cnr/temp
# 24th Jun 2010  eweb     #00008 temporary files from schemadiff
#  8th Aug 2010  eweb     #00008 Delete extrainfo.tmp, *.log; ignore media, *.suo
# 19th Aug 2010  eweb     #00008 Don't open empty file
#  1st Nov 2010  eweb     #00008 Adhoc schema status
# 29th Mar 2011  eweb     #00008 jasper, schema reg and tz
# 11th May 2011  eweb     #00008 tidy up, more thorough on wendy
#

#
# Usage delall.pl [driveletter] [drive]
#

use strict;

my $driveletter;
my $drive = $ARGV[0];
my $edit = $ARGV[1];
my $all = $ARGV[2];
my $justList;
my $debug;

if ( $edit eq "" ) {
  $edit = "y";
}
if ( $edit eq "ls" ) {
  $justList = "y";
  $edit = "y";
}

if ( lc $ENV{COMPUTERNAME} eq "wendy" ) {
  $all = 1;
}

if ( $drive =~ /(.):/ ) {
  $driveletter = $1;
}
elsif ( $drive =~ /^.$/ ) {
  $driveletter = $drive;
  $drive = $driveletter . ":";
}

if ( $justList eq "" ) {
  foreach ( glob( "$drive\\topclass\\oracle\\topclass\\Scripts\\Tools\\SchemaDiff\\ORACLE\\config\\*" ) ) {
  if ( -d $_ ) {
    if ( /sizing$/ ) {
    }
    else {
      print "$_\n";
      RmDir( $_ );
    }
  }
}

DeleteFile( "$drive\\topclass\\oracle\\topclass\\Scripts\\Tools\\SchemaDiff\\ORACLE\\*.tclog" );
DeleteFile( "$drive\\topclass\\oracle\\topclass\\Scripts\\Tools\\SchemaDiff\\ORACLE\\*.log" );

RmDir( "$drive\\topclass\\oracle\\topclass\\debug" );
RmDir( "$drive\\topclass\\oracle\\topclass\\release" );
RmDir( "$drive\\topclass\\oracle\\topclass\\Neo\\debug" );
RmDir( "$drive\\topclass\\oracle\\topclass\\Neo\\release" );
RmDir( "$drive\\topclass\\oracle\\topclass\\player\\debug" );
RmDir( "$drive\\topclass\\oracle\\topclass\\player\\release" );
RmDir( "$drive\\topclass\\oracle\\topclass\\oHtmlParser\\Release" );
RmDir( "$drive\\topclass\\oracle\\topclass\\oHtmlParser\\Debug" );
RmDir( "$drive\\topclass\\oracle\\topclass\\alerts\\Release" );
RmDir( "$drive\\topclass\\oracle\\topclass\\alerts\\debug" );

RmDir( "$drive\\topclass\\oracle\\topclass\\x64" );
RmDir( "$drive\\topclass\\oracle\\topclass\\Neo\\x64" );
RmDir( "$drive\\topclass\\oracle\\topclass\\player\\x64" );
RmDir( "$drive\\topclass\\oracle\\topclass\\oHtmlParser\\x64" );
RmDir( "$drive\\topclass\\oracle\\topclass\\alerts\\x64" );

DeleteFile( "$drive\\topclass\\oracle\\topclass\\sources\\kDefault*Template.inc" );
DeleteFile( "$drive\\topclass\\oracle\\topclass\\sources\\kDefault*Xml.inc" );

RmDir( "$drive\\topclass\\oracle\\plugins\\debug" );
RmDir( "$drive\\topclass\\oracle\\plugins\\release" );
RmDir( "$drive\\topclass\\oracle\\plugins\\x64" );
RmDir( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\xmlif\\ifparserdll\\debug" );
RmDir( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\xmlif\\ifparserdll\\release" );
DeleteFile( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\xmlif\\ifparserdll\\ifparser_parser.output" );
DeleteFile( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\xmlif\\ifparserdll\\ifparser_parser.tab.c" );

RmDir( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\ws\\java\\build" );
RmDir( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\ws\\parser\\build" );
RmDir( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\ws\\gsoap" );
RmDir( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\ws\\gsoap_home\\Debug" );
RmDir( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\ws\\gsoap_home\\Release" );
RmDir( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\ws\\gsoap_home\\x64" );
RmDir( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\ws\\antlr_home\\lib\\cpp\\Debug" );
RmDir( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\ws\\antlr_home\\lib\\cpp\\Release" );
RmDir( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\ws\\antlr_home\\lib\\cpp\\x64" );

DeleteFiles( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\kDefault*Template.inc" );

RmDir( "$drive\\topclass\\oracle\\topclass\\clr_procs\\bin" );
RmDir( "$drive\\topclass\\oracle\\topclass\\clr_procs\\obj" );
DeleteFiles( "$drive\\topclass\\oracle\\topclass\\Scripts\\MSSQL\\Internal\\ServerProcs\\wbt_clr_procs.dll" );

chdir( "$drive\\" );
system( "delauth.pl $drive" );


DeleteFile( "$drive\\topclass\\oracle\\topclass\\bsapi.log" );
DeleteFile( "$drive\\topclass\\oracle\\topclass\\*.ncb" );
DeleteFile( "$drive\\topclass\\oracle\\topclass\\*.plg" );
DeleteFile( "$drive\\topclass\\oracle\\plugins\\*.ncb" );
DeleteFile( "$drive\\topclass\\oracle\\plugins\\*.plg" );
DeleteFile( "$drive\\topclass\\oracle\\topclass\\alerts\\*.plg" );
DeleteFile( "$drive\\topclass\\oracle\\topclass\\oHtmlParser\\*.plg" );
DeleteFile( "$drive\\topclass\\oracle\\topclass\\keygen\\*.ncb" );

DeleteFile( "$drive\\topclass\\oracle\\topclass\\www\\*.lib" );
DeleteFile( "$drive\\topclass\\oracle\\topclass\\www\\*.exp" );
DeleteFile( "$drive\\topclass\\oracle\\topclass\\www\\*.map" );
DeleteFile( "$drive\\topclass\\oracle\\topclass\\www\\*.pdb" );
DeleteFile( "$drive\\topclass\\oracle\\topclass\\www\\*.ilk" );
DeleteFile( "$drive\\topclass\\oracle\\topclass\\www\\*.bsc" );
DeleteFile( "$drive\\topclass\\oracle\\topclass\\www\\*.dll" );
DeleteFile( "$drive\\topclass\\oracle\\topclass\\www\\*.exe" );

RmDir( "$drive\\topclass\\oracle\\topclass\\www\\qpi" );
RmDir( "$drive\\topclass\\oracle\\topclass\\www\\spi" );
RmDir( "$drive\\topclass\\oracle\\topclass\\www\\cpi" );
RmDir( "$drive\\topclass\\oracle\\topclass\\www\\SqlServer" );
RmDir( "$drive\\topclass\\oracle\\topclass\\working" );
RmDir( "$drive\\topclass\\oracle\\topclass\\scripts\\mssql\\log" );
DeleteFile( "$drive\\topclass\\oracle\\topclass\\Lisp\\getdoc.lsp" );
DeleteFile( "$drive\\topclass\\oracle\\topclass\\Lisp\\getdoc.tmp" );
DeleteFile( "$drive\\topclass\\oracle\\topclass\\Lisp\\extrainfo.tmp" );
RmDir( "$drive\\topclass\\oracle\\topclass\\lisp\\gen" );
RmDir( "$drive\\topclass\\oracle\\topclass\\lisp\\current" );
RmDir( "$drive\\topclass\\oracle\\topclass\\doc\\main" );
RmDir( "$drive\\topclass\\oracle\\topclass\\doc\\37" );
RmDir( "$drive\\topclass\\oracle\\topclass\\doc\\38" );
RmDir( "$drive\\topclass\\oracle\\topclass\\doc\\39" );
RmDir( "$drive\\topclass\\oracle\\topclass\\doc\\40" );
RmDir( "$drive\\topclass\\oracle\\topclass\\doc\\41" );
DeleteFile( "$drive\\topclass\\oracle\\topclass\\doc\\formats.html" );
RmDir( "$drive\\topclass\\oracle\\plugins\\bin" );
RmDir( "$drive\\utils\\AutoDevBuild\\SQL\\scripts" );

DeleteFile( "$drive\\utils\\SCORMApplet\\SCORM1.1\\*.class" );
DeleteFile( "$drive\\utils\\SCORMApplet\\SCORM1.1\\*.jar" );
DeleteFile( "$drive\\utils\\SCORMApplet\\SCORM1.2\\*.class" );
DeleteFile( "$drive\\utils\\SCORMApplet\\SCORM1.2\\*.jar" );

RmDir( "$drive\\utils\\SCORMApplet\\SCORM1.2\\out" );

DeleteFile( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\report\\crystal\\VB\\cr_report.exe" );
DeleteFile( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\report\\crystal\\VBV-LangUtils\\CRUFLwbt.dll" );
DeleteFile( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\report\\crystal\\VBV-LangUtils\\CRUFLwbt.exp" );
DeleteFile( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\report\\crystal\\VBV-LangUtils\\CRUFLwbt.lib" );

RmDir( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\report\\crystal\\VB\\cr_report.net\\obj" );
RmDir( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\report\\crystal\\VB\\cr_report.net\\bin" );
RmDir( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\report\\crystal\\VB\\cr_report.net\\My Project" );

RmDir( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\report\\crystal\\VBV-LangUtils\\CRUFLwbt.NET\\obj" );
RmDir( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\report\\crystal\\VBV-LangUtils\\CRUFLwbt.NET\\bin" );
RmDir( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\report\\crystal\\VBV-LangUtils\\CRUFLwbt.NET\\My Project" );

RmDir( "$drive\\utils\\TopClassDB\\TopClassDB.NET\\bin" );
RmDir( "$drive\\utils\\TopClassDB\\TopClassDB.NET\\obj" );
RmDir( "$drive\\utils\\TopClassDB\\TopClassDB.NET\\My Project" );

DeleteFile( "$drive\\topclass\\java\\cnr\\cnr.war" );

RmDir( "$drive\\topclass\\java\\cnr\\temp" );
RmDir( "$drive\\topclass\\java\\cnr\\work" );
RmDir( "$drive\\topclass\\java\\cnr\\web\\WEB-INF" );
RmDir( "$drive\\topclass\\java\\cnr\\web-inf" );
RmDir( "$drive\\topclass\\java\\cnr\\build" );

RmDir( "$drive\\topclass\\java\\jasperserver\\build" );

DeleteFile( "$drive\\topclass\\java\\topclass\\topclass.war" );
RmDir( "$drive\\topclass\\java\\topclass\\build" );
DeleteFile( "$drive\\topclass\\java\\topclass\\cobertura.ser" );
DeleteFile( "$drive\\topclass\\java\\topclass\\WebContent\\tcmessages_*.js" );
DeleteFile( "$drive\\topclass\\java\\topclass\\abc.txt" );
DeleteFile( "$drive\\topclass\\java\\topclass\\Completions.txt" );

RmDir( "$drive\\topclass\\oracle\\topclass\\keygen\\Debug" );
RmDir( "$drive\\topclass\\oracle\\topclass\\keygen\\Release" );
RmDir( "$drive\\topclass\\oracle\\topclass\\keygen\\x64" );

DeleteFile( "$drive\\utils\\TopClassDB\\TopClassDB.dll" );
DeleteFile( "$drive\\utils\\TopClassDB\\TopClassDB.exp" );
DeleteFile( "$drive\\utils\\TopClassDB\\TopClassDB.lib" );
DeleteFile( "$drive\\3rdparty\\Tools\\gsoap\\gsoap-2.7\\gsoap.exe" );
DeleteFile( "$drive\\3rdparty\\Tools\\gsoap\\gsoap-2.7\\gsoap.ilk" );
RmDir( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\ws\\gsoap_home\\Debug" );
RmDir( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\ws\\gsoap_home\\Release" );
RmDir( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\ws\\gsoap_home\\x64" );
RmDir( "$drive\\3rdparty\\Tools\\antlr\\antlr-2.7.5\\lib\\cpp\\Debug" );
RmDir( "$drive\\3rdparty\\Tools\\antlr\\antlr-2.7.5\\lib\\cpp\\Release" );
RmDir( "$drive\\3rdparty\\Tools\\antlr\\antlr-2.7.5\\lib\\cpp\\x64" );

DeletePatterns( "$drive", " *.bak *.contrib *.contrib.* *.ann *.old *.log" );

DeleteFile( "$drive\\authoring\\suite\\workspace\\*.log" );

DeleteFile( "$drive\\topclass\\oracle\\topclass\\languages\\*.lang" );
DeleteFile( "$drive\\topclass\\oracle\\topclass\\languages\\*.labels" );
DeleteFile( "$drive\\topclass\\oracle\\topclass\\www\\SQLServer\\*.dll" );

DeleteFile( "$drive\\topclass\\oracle\\topclass\\www\\language\\*.lang" );
DeleteFile( "$drive\\topclass\\oracle\\topclass\\www\\language\\*.labels" );
DeleteFile( "$drive\\topclass\\oracle\\topclass\\www\\tcmessages_*.js" );


RmDir( "$drive\\topclass\\oracle\\topclass\\www\\qpi" );
RmDir( "$drive\\topclass\\oracle\\topclass\\www\\spi" );
RmDir( "$drive\\topclass\\oracle\\topclass\\www\\cpi" );

DeletePatterns( "$drive\\topclass\\oracle\\install\\projects", " *.log *.rpt *.dbg *.inx *.map *.obs" );

RmDir( "$drive\\topclass\\oracle\\install\\projects\\MSSQLInstaller\\Media\\MSSQLInstaller\\Disk Images" );
RmDir( "$drive\\topclass\\oracle\\install\\projects\\OracleInstaller\\Media\\OracleInstaller\\Disk Images" );
RmDir( "$drive\\topclass\\oracle\\install\\projects\\Publisher\\Media\\Publisher\\Disk Images" );
RmDir( "$drive\\topclass\\oracle\\install\\projects\\TopClassMobile\\Media\\TopClassMobile\\Disk Images" );
RmDir( "$drive\\topclass\\oracle\\install\\projects\\TopClassServer\\Media\\TopClassServer\\Disk Images" );

DeleteFile( "$drive\\topclass\\oracle\\topclass\\Scripts\\MSSQL\\db_account_*" );
DeleteFile( "$drive\\topclass\\oracle\\topclass\\Scripts\\MSSQL\\db_schema_*" );
DeleteFile( "$drive\\topclass\\oracle\\topclass\\Scripts\\MSSQL\\rpts_account_*" );
DeleteFile( "$drive\\topclass\\oracle\\topclass\\Scripts\\MSSQL\\rpts_schema_*" );
DeleteFile( "$drive\\topclass\\oracle\\topclass\\Scripts\\MSSQL\\descript.ion" );
DeleteFile( "$drive\\topclass\\oracle\\topclass\\Scripts\\ORACLE\\__Logs\\*.log" );


DeleteFile( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\ws\\gsoap_home\\gsoap.exe" );
DeleteFile( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\ws\\gsoap_home\\gsoap.ilk" );
DeleteFile( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\ws\\parser\\src\\SQLLexer.java" );
DeleteFile( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\ws\\parser\\src\\SQLLexerTokenTypes.*" );
DeleteFile( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\ws\\parser\\src\\SQLParser.java" );
DeleteFile( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\ws\\parser\\src\\parsercpp.g" );
DeleteFile( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\ws\\parser\\src\\parserjava.g" );
DeleteFile( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\ws\\SQLLexer.*" );
DeleteFile( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\ws\\SQLLexerTokenTypes.*" );
DeleteFile( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\ws\\SQLParser.*" );
DeleteFile( "$drive\\topclass\\oracle\\plugins\\sources\\cpi\\ws\\java\\project\\*status.txt" );

DeleteFiles( "$drive\\topclass\\oracle\\topclass\\Scripts\\Tools\\*.diff" );
DeleteFiles( "$drive\\topclass\\oracle\\topclass\\Scripts\\Tools\\*.log" );
DeleteFiles( "$drive\\topclass\\oracle\\topclass\\Scripts\\Tools\\*.temp" );

DeleteFile( "$drive\\topclass\\oracle\\topclass\\sources\\tz\\yearistype" );
DeleteFile( "$drive\\topclass\\oracle\\topclass\\sources\\tz\\tzselect" );

if ( $all ) {
  RmDir( "$drive\\topclass\\oracle\\topclass\\www\\language" );
  RmDir( "$drive\\topclass\\oracle\\topclass\\www\\attach" );

  DeleteFile( "$drive\\topclass\\oracle\\topclass\\www\\dat\\browser.txt" );
  DeleteFile( "$drive\\topclass\\oracle\\topclass\\www\\dat\\icons.dat" );
  DeleteFile( "$drive\\topclass\\oracle\\topclass\\www\\dat\\server.txt" );
  DeleteFile( "$drive\\topclass\\oracle\\topclass\\www\\message.txt" );
  DeleteFile( "$drive\\topclass\\oracle\\topclass\\topclass.opt" );
  DeleteFile( "$drive\\topclass\\oracle\\topclass\\topclass.suo" );
  DeleteFile( "$drive\\topclass\\oracle\\plugins\\plugins.opt" );
  DeleteFile( "$drive\\topclass\\oracle\\plugins\\plugins.suo" );
}

DeleteFile( "$drive\\utils\\AutoDevBuild\\cnr_persist.properties" );

}

#pushd
#$drive
chdir( "$drive\\" );

#REM .vcproj.WEST.eweb.user
#REM [checkedout]
#REM \\topclass\\oracle\\topclass\\www\\language

my $ctool = "cleartool";
if ( lc $ENV{COMPUTERNAME} eq "roo" ) {
  $ctool = "escc";
}

my $any;
my $privates = "c:\\temp\\$driveletter-privs.bat";
if ( open( PRIVS, "$ctool lspriv 2>&1 |" ) ) {
  if ( open( PRIVSOUT, ">$privates" ) ) {
    while ( <PRIVS> ) {
      $_ = dosify($_);
      if ( /\.vcproj\.WEST\.eweb\.user/ ||
         /\[checkedout\]/ ||
         /topclass\\oracle\\topclass\\www\\language/ ||
         /topclass\\oracle\\topclass\\www\\reports/ ||
         /topclass\\oracle\\topclass\\www\\message.*\.txt/ ||
         /topclass\\oracle\\topclass\\www\\topclass\.lic/ ||
         /topclass\\oracle\\topclass\\www\\media/ ||
         /topclass\\oracle\\topclass\\sources\\templates\\[bB]ug[0-9]+\.tmpl/
         ) {
      }
      elsif ( /patches\\/ ) {
      }
      elsif ( /\.suo$/ ) {
      }
      else {
        $any = 1;
        print PRIVSOUT;
      }
    }
    close( PRIVSOUT );
  }
  close( PRIVS );
}

## use fork because we don't want to wait for textpad to exit.
if ( $any ) {
  if ( $edit ne "n" ) {
    print "textpad $privates\n";
    print "cleartool lspriv\n";
    my $pid = fork();
    die "fork() failed: $!" unless defined $pid;
    if ( $pid ) {
      exec "textpad", $privates;
    }
  }
  else {
    system( "type $privates" );
  }
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
  if ( $file =~ /\*/ ) {
    if ( glob( $file ) ) {
      my $cmd = "del /f $file";
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

sub DeletePatterns( $$ ) {
  my ($dir, $patterns) = @_;

  $patterns =~ s! ! $dir\\!g;

  DeleteFiles( $patterns );
}

sub dosify($) {
  my ($path) = @_;
  $path =~ s!/!\\!g;
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

