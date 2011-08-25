#
# File: copyprivs.pl
# Copy the view private files (not checked out) to a different directory
#

use strict;
use File::Glob;
use File::Copy;
use File::Basename;

my $verbose;

my $ViewTag = $ARGV[0];
my $KeepDir = $ARGV[1];
my $list    = $ARGV[2];

if ( $ViewTag eq "" )
  {
    print "usage: $0 viewtag keepdir\n";
    exit;
  }
if ( $KeepDir eq "" )
  {
    $KeepDir = $ENV{TEMP};
  }
if ( ! -d $KeepDir )
  {
    MkDir( $KeepDir );
  }
if ( ! -d $KeepDir )
  {
    print "$KeepDir does not exist and couldn't be created\n";
    exit;
  }

my $copyfiles = $ENV{TEMP} . "\\$ViewTag-privs.txt";

#open( COPYLOG, ">$copyfiles" ) or die "Can't open $copyfiles\n";

if ( ! -d $KeepDir )
  {
    MkDir( $KeepDir );
  }
if ( ! -d "$KeepDir\\$ViewTag" )
  {
    MkDir( "$KeepDir\\$ViewTag" );
  }

system( "cleartool catcs -tag $ViewTag > $KeepDir\\$ViewTag\\config.spec" );

open( PRIVATES, "cleartool lspriv -tag $ViewTag |");

while ( <PRIVATES> )
  {
    chomp;
    if ( /\[checkedout\]/ )
      {
      }
    elsif ( /\.obj$/ ||
            /\.sbr$/ ||
            /\.dll$/ ||
            /\.exe$/ ||
            /\.exp$/ ||
            /\.ilk$/ ||
            /\.lib$/ ||
            /\.map$/ ||
            /\.ncb$/ ||
            /\.opt$/ ||
            /\.plg$/ ||
            /\.pch$/ ||
            /\.idb$/ ||
            /\.res$/ ||
            /\.bsc$/ ||
            /\.log$/ ||
            /\.pch$/ ||
            /\.pdb$/ )
      {
      }
    elsif ( /\.vcproj\..+\.user$/ )
      {
      }
    elsif ( /\.old$/ ||
            /\.contrib$/ ||
            /\.contrib\.[0-9]+$/ ||
            /\.bak$/ )
      {
      }
    elsif ( /\\topclass\\oracle\\topclass\\languages\\.+_abc.dat$/ )
      {
      }
    elsif ( /dlldata\.c$/ ||
            /\.tlh$/ ||
            /\.tli$/ ||
            /\.tlb$/ ||
            /\.trg$/ ||
            /_p\.c$/ ||
            /_i\.c$/ )
      {
      }
    elsif ( /\\authoring\\utilities\\SCORM\\tcSCORMdoccom\\common_interface\.h$/ ||
            /\\authoring\\utilities\\SCORM\\tcSCORMdoccom\\tcSCORMdoccom\.h$/ ||
            /\\authoring\\utilities\\Scorm2Plug\\Scorm2Plug\.h$/ ||
            /\\authoring\\utilities\\SCORM\\scorm1\.2\\tcSCORM12Import\\tcSCORM12Import\.h$/ ||
            /\\authoring\\utilities\\tcworddoccom\\tcworddoccommod\\TCWordDocComMod\.h$/ ||
            /\\authoring\\utilities\\TCServerDacPrj\\TCServerDacMod\\TCServerDacMod\.h$/ ||
            /\\authoring\\assistant\\tcmetadatamod\\MetaDLLMod\.h$/ ||
            /\\authoring\\utilities\\tcqpimgr\\tcqpimgr\.h$/ ||
            /\\authoring\\utilities\\tcpowerpointdoccom\\tcpowerpointdoccommod\\TCPowerPointDocComMod\.h$/ ||
            /\\authoring\\utilities\\TCPlugDacPrj\\TCPlugDacMod\\TCPlugDacMod\.h$/ ||
            /\\authoring\\utilities\\tccomverter\\tccomverter\.h$/ ||
            /\\authoring\\utilities\\tccomverter\\tctypedefs\.h$/ ||
            /\\authoring\\utilities\\exactml\\tmlupgrader\\tmlupgrader\.h$/ ||
            /\\authoring\\utilities\\SCORM\\scorm1\.2\\tcSCORMExport\\common_interface\.h$/ ||
            /\\authoring\\utilities\\SCORM\\scorm1\.2\\tcSCORMExport\\tcSCORMExport\.h$/ ||
            /\\authoring\\utilities\\AICC\\TcAICCExport\\TcAICCExport\.h$/ ||
            /\\authoring\\utilities\\AICC\\TcAICCExport\\common_interface\.h$/ ||
            /\\authoring\\utilities\\AICC\\tcAICCdoccom\\common_interface\.h$/ ||
            /\\authoring\\utilities\\AICC\\tcAICCdoccom\\tcAICCdoccom\.h$/ ||
            /\\authoring\\utilities\\tclangreader\\tclangreader\.h$/ ||
            /\\authoring\\utilities\\tchtmlgenerate\\tchtmlgenerate\.h$/ ||
            /\\authoring\\utilities\\htmlclean\\htmlclean\.h$/ ||
            /\\authoring\\utilities\\DAC\\Include\\DACCommonInterfaces\.h$/ ||
            /\\authoring\\utilities\\tcbase64\\tcbase64mod\\TCBase64Mod\.h$/ ||
            /\\authoring\\utilities\\SCORM\\scorm1\.2\\tcSCORMExport\\common interface\.h$/ ||
            /\\authoring\\utilities\\SCORM\\scorm1\.2\\tcSCORM12Import\\common interface\.h$/ ||
            /\\authoring\\utilities\\AICC\\tcAICCdoccom\\common interface\.h$/ ||
            /\\authoring\\utilities\\AICC\\TcAICCExport\\common interface\.h$/ ||
            /\\authoring\\utilities\\SCORM\\tcSCORMdoccom\\common interface\.h$/ ||
            /\\authoring\\utilities\\DAC\\Include\\DAC Common Interfaces\.h$/ ||
            /\\topclass\\oracle\\plugins\\sources\\cpi\\ws\\java\\project\\debugstatus\.txt$/ ||
            /\\topclass\\oracle\\plugins\\sources\\cpi\\ws\\java\\project\\releasestatus\.txt$/ )
      {
      }
    elsif ( /\.ann$/ ||
            /\.bak$/ ||
            /~$/ ||
            /\\~/ ||
            /\.contrib$/ ||
            /\.contrib\.[0-9]+$/ )
      {
      }
    elsif ( -d $_ )
      {
      }
    elsif ( /\kDefault.*Template\.inc$/ ||
            /\kDefault.*Xml\.inc$/ )
      {
      }
    elsif ( /\\.class$/ )
      {
      }
    elsif ( /\\ws\\gsoap\\/ ||
            /\\ws\\parser\\build\\/ ||
            /\\ws\\java\\build\\/ )
      {
      }
    elsif ( /\\www\\message\.txt/ ||
            /\\www\\message[0-9]+\.txt/ ||
            /\\www\\dat\\browser\.txt/ ||
            /\\www\\dat\\server\.txt/ ||
            /\.lang/ ||
            /\.labels/ ||
            /\\www\\dat\\icons\.dat/ )
      {
      }
    elsif ( /<DIR/ )
      {
        print "Dodgy dir $_\n" if ( $verbose );
      }
    elsif ( /\@\@/ )
      {
        print "Dodgy version $_\n" if ( $verbose );
      }
    else
      {
        print "$_\n";
        if ( /^.:(.+)/ )
          {
            if ( $list eq "" )
              {
                print "copy $_ $KeepDir$1 /p\n";
              }
            else
              {
                copyFile( $_, "$KeepDir$1", "/p" );
              }
          }
      }
  }

close(PRIVATES);
close(COPYLOG);

sub copyFile()
  {
    my ($source, $dest, $flags) = @_;

    #print COPYLOG "copy $flags $source $dest\n";

    my ($nameS, $pathS, $suffixS) = fileparse($source);
    my ($nameD, $pathD, $suffixD) = fileparse($dest);

    #print COPYLOG "Source ($nameS, $pathS, $suffixS)\n";
    #print COPYLOG "Dest   ($nameD, $pathD, $suffixD)\n";

    if ( $flags eq "/p" )
      {
        if ( !-d $pathD )
          {
            MkDir( $pathD );
          }
      }

    if ( -e $dest )
      {
        # copying to a file that exists?
      }
    if ( -e $source )
      {
        my $destFile = $dest;
        if ( -d $dest )
          {
            # copying to a directory
            $destFile = "$dest\\$nameS$suffixS";
          }
        elsif ( $nameD eq "" )
          {
            #destination is a directory
            MkDir( $dest );
            $destFile = "$dest\\$nameS$suffixS";
          }
        else
          {
            if ( $nameS =~ /\./ )
              {
                if ( $nameD !~ /\./ )
                  {
                    print "**** Perhaps destination $dest is a directory\n";
                    print COPYLOG "**** Perhaps destination $dest is a directory\n";
                  }
              }
          }
        if ( copy( $source, $destFile ) )
          {
            print COPYLOG "$source => $destFile\n";
          }
        else
          {
            print COPYLOG "**** $source => $destFile FAILED $!\n";
          }
      }
    elsif ( -d $source )
      {
        print COPYLOG "?????? copy directory $source $dest\n";
      }
    elsif ( $source =~ /[\?\*]/ ) # globbing
      {
        print COPYLOG "copy glob $source $dest\n";
        my @sources = File::Glob::bsd_glob( $source );
        if ( $#sources == 0 )
          {
            print COPYLOG "**** $source no files\n";
          }
        else
          {
            MkDir( $dest );
            foreach (@sources)
              {
                my ($name, $path, $suffix) = fileparse($_);
                if ( copy( $_, "$dest\\$name$suffix" ) )
                  {
                    print COPYLOG "$_ => $dest\\$name$suffix\n";
                  }
                else
                  {
                    print COPYLOG "**** $_ => $dest\\$name$suffix FAILED $!\n";
                  }
              }
          }
      }
    else
      {
        print COPYLOG "**** $source file not found\n";
      }

    if ( $flags eq "/s" or $flags eq "/e" )
      {
        my ($name, $srcDir, $suffix) = fileparse($source);
        my $dir;
        if ( opendir( $dir, $srcDir) )
          {
            my $subdir;
            while ( defined( $subdir = readdir($dir) ) )
              {
                if ( $subdir eq "." or $subdir eq ".." )
                  {
                  }
                elsif ( -d "$srcDir$subdir" )
                  {
                    #MakeDirectory( "$dest\\$subdir" );
                    copyFile( "$srcDir$subdir\\$name$suffix", "$dest\\$subdir", $flags );
                  }
              }
            closedir($dir);
          }
      }
  }

sub MkDir($)
  {
    my ($dir) = @_;
    if ( -d $dir )
      {
        #print COPYLOG "MkDir $dir exists\n";
      }
    else
      {
        my $sofar = "";
        foreach ( split( /\\/, $dir ) )
          {
            if ( $sofar eq "" )
              {
                $sofar = $_;
              }
            else
              {
                $sofar = "$sofar\\$_";
                if ( -d $sofar )
                  {
                    #print COPYLOG "MkDir $sofar exists\n";
                  }
                elsif ( mkdir( $sofar ) )
                  {
                    #print COPYLOG "MkDir $dir\n";
                  }
                else
                  {
                    print COPYLOG "MkDir $sofar FAILED! $!\n";
                    return 0;
                  }
              }
          }
        #print COPYLOG "MkDir $dir\n";
      }
  }


