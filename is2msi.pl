#******************************************************************************/
#
#  File: is2msi.pl
#  Author: eweb
#  Copyright WBT Systems, 2007
#  Contents: Help to Convert Install shield scripts to wix
#
#******************************************************************************/
#
#   Date:          Author:  Comments:
#   19th Jan 2007  eweb     Initial version.
#

use strict;
use File::Glob;
use File::Copy;
use File::Basename;

my $projectDir = $ARGV[0];
if ( $projectDir eq "" )
  {
    $projectDir = ".";
  }

my $BUILDROOT = "b:\\TopClassV7.4.2\\builds\\build022\\";
if ( lc $ENV{COMPUTERNAME} eq "roo" )
  {
    $BUILDROOT = "c:\\TopClassV7.4.2\\builds\\build021\\";
  }

# build up a has of hashes...
my @targetDirs;

if ( !open( FDF, "$projectDir\\File Groups\\Default.fdf" ) )
  {
    die "Can't open \"$projectDir\\File Groups\\Default.fdf\"\n";
  }
else
  {
    while ( <FDF> )
      {
        chomp;
        if ( /^TARGET=(.*)$/ )
          {
            my $t = $1;
            my $p = quotemeta($t);
            if ( !grep( /^$p$/, @targetDirs ) )
              {
                @targetDirs = (@targetDirs, $t);
              }
          }
      }
    close(FDF);
  }



    print "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
    print "<Wix xmlns=\"http://schemas.microsoft.com/wix/2006/wi\">\n";
    print "  <Product Id=\"{12345678-1234-1234-1234-000000000001}\" Name=\"123 TopClass\" Language=\"1033\" Version=\"1.0.0.0\" Manufacturer=\"WBT Systems\"\n";
    print "           UpgradeCode=\"{12345678-1234-1234-1234-000000000001}\">\n";
    print "    <Package Description=\"TopClass Server\" Comments=\"This will appear in the file summary stream.\" InstallerVersion=\"200\" Compressed=\"yes\" />\n";
    print "\n";
    print "    <Media Id=\"1\" Cabinet=\"topclass.cab\" EmbedCab=\"yes\" />\n";
    print "\n";
    print "    <UIRef Id=\"WixUI_Mondo\" />\n";
    print "    <UIRef Id=\"WixUI_ErrorProgressText\" />\n";
   #print "    <Property Id=\"WixUI_InstallDir\" Value=\"INSTALLLOCATION\" />\n";
    print "\n";

    my $sectionNo = 0;
    my @features;

@targetDirs = sort( @targetDirs );
@targetDirs = reverse( @targetDirs );

    foreach ( @targetDirs )
      {
        if ( /<svOracleScriptsDir>/ ||
             /<svTCCPath>/ ||
             /<svApacheRoot>/ ||
             /<WINSYSDIR>/ )
          {
          }
        elsif ( /^<(.+)>$/ )
          {
            my $target = uc $1;
            if ( $target eq "TARGETDIR" )
              {
                $target = "MYTARGETDIR";
              }
            print "    <Property Id=\"$target\" Value=\"$target\" />\n";
          }
      }

    print "    <Directory Id=\"TARGETDIR\" Name=\"SourceDir\">\n";

    my $target = pop( @targetDirs );
    while ( $target )
      {
        doATargetDir( $target );
        $target = pop( @targetDirs );
      }

    print "    </Directory>\n";

    foreach my $feature ( @features )
      {
        print "    <Feature Id=\"$feature\" Title=\"$feature\" Level=\"1\">\n";
        print "      <ComponentRef Id=\"$feature\" />\n";
        print "    </Feature>\n";
      }
    print "  </Product>\n";
    print "</Wix>\n";

sub doATargetDir( $ )
  {
    my ( $target ) = @_;
    if ( $target eq "<TARGETDIR>\\language" )
      {
        return;
      }
    if ( $target eq "<TARGETDIR>\\dat" )
      {
        return;
      }
    if ( $target eq "<TARGETDIR>\\documentation" )
      {
        return;
      }
    if ( $target eq "<TARGETDIR>\\reports" )
      {
        return;
      }
    if ( $target =~ /<svWebableDir>\\Reports/ ||
         $target =~ /<svOracleScriptsDir>/ ||
         $target =~ /<svTCCPath>/ ||
         $target =~ /<svApacheRoot>/ ||
         $target =~ /<WINSYSDIR>/ )
      {
        return;
      }
    print "<!-- $target -->\n";

    my $fdf;
    if ( !open( $fdf, "$projectDir\\File Groups\\Default.fdf" ) )
      {
        die "Can't open \"$projectDir\\File Groups\\Default.fdf\"\n";
      }
    else
      {
        my $isAVar = 0;
        my $targetName = $target;
        if ( $targetName =~ /^<(.+)>$/ )
          {
            $targetName = uc $1;
            $isAVar = 1;
          }
        elsif ( $targetName =~ /\\([^\\]+)$/ )
          {
            $targetName = $1;
          }
        if ( $targetName eq "TARGETDIR" )
          {
            $targetName = "MYTARGETDIR";
          }
        print "    <Directory Id=\"$targetName\" Name=\"$targetName\">\n";

        my $section;
        my %fileGroup;
        while ( <$fdf> )
          {
            chomp;
            if ( /^\[(.+)\]$/ )
              {
                %fileGroup = undef;
                $fileGroup{fileGroupName} = $1;
                $section = $1;
              }
            elsif ( /^$/ )
              {
                # end of file group...
                if ( open( FGL, "$projectDir\\File Groups\\$section.fgl" ) )
                  {
                    while ( <FGL> )
                      {
                        chomp;
                        if ( /^([^=]+)=(.*)$/ )
                          {
                            #if ( $section ne "FileGroups" and $section ne "Info" )
                              {
                                #print "setting fileGroup{$1} = $2\n";
                                $fileGroup{$1} = $2;
                              }
                          }
                        #print "$_\n";
                      }
                    close( FGL );
                  }

                next if ( $section eq "FileGroups" or $section eq "Info" );

                if ( $fileGroup{TARGET} eq $target )
                  {
                    $section =~ s/-/_/g;
                    $section =~ s/ /_/g;
                    #print "<!-- $section -->\n";
                    #for my $k ( keys( %fileGroup ) )
                    #  {
                    #    if ( $k )
                    #      {
                    #        print "$k: " . $fileGroup{$k} . "\n";
                    #      }
                    #  }
                    #print "-->\n";
                    my $file = $fileGroup{WILDCARD0};
                    next if ( $file eq "" );
                    next if ( $file eq "competenciesu.dll" );
                    next if ( $file eq "sql_report.exe" );
                    next if ( $file eq "TCReport.css" );

                    @features = ( $section, @features );

                    my $sourceFolder = $fileGroup{FOLDER};
                    $sourceFolder =~ s!<BUILD>\\!!;
                    $sourceFolder =~ s!<BUILD>!!;
                    print "          <Component Id=\"$section\" Guid=\"{12345678-1234-1234-1234-000000001" . sprintf( "%03d", $sectionNo ) . "}\">\n";

                    my @files = File::Glob::bsd_glob( "$BUILDROOT$sourceFolder\\$file" );
                    my $nFiles = 0;
                    for my $filepath ( @files )
                      {
                        if ( -e $filepath )
                          {
                            my ($file, $path, $suffix) = fileparse($filepath);
                            my $id = $file;
                            $id =~ s/\./_/g;
                            $id =~ s/_/_/g;
                            $id =~ s/ /_/g;
                            print "            <File Id='${section}_$id' Name='$file' DiskId='1' Source='$path$file' />\n";
                            $nFiles++;
                          }
                      }
                    if ( $nFiles == 0 )
                      {
                        print "            <CreateFolder />\n";
                      }

                    print "          </Component>\n";
                    $sectionNo++;
                    #last;
                  }
              }
            elsif ( /^([^=]+)=(.*)$/ )
              {
                #if ( $section ne "FileGroups" and $section ne "Info" )
                  {
                    #print "setting fileGroup{$1} = $2\n";
                    $fileGroup{$1} = $2;
                  }
              }
          }
        close( $fdf );
        my $nextTarget = pop( @targetDirs );
        while ( $nextTarget && $nextTarget =~ /^$target/ ) # a sub folder
          {
            doATargetDir( $nextTarget );
            $nextTarget = pop( @targetDirs );
          }
         if ( $nextTarget )
          {
            push( @targetDirs, $nextTarget );
          }
        print "    </Directory>\n";
        print "\n";
      }
  }

