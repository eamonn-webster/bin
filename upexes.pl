use strict;

my $Builds = "\\\\radon\\builds";
my $Major;
my $Minor;
my $Point;
my $Build;
my $testing;
my $nonwebroot = "\\topclass\\oracle\\topclass\\www";

sub GetBuildNumber( $ )
{
  my ($drive) = @_;

  my $BuildNoFile = "$drive/topclass/oracle/topclass/sources/buildno.h";
  if ( ! -e $BuildNoFile )
    {
      my $VersionInfoFile = "$drive/topclass/oracle/topclass/sources/versioninfo.h";
      if ( -e $VersionInfoFile )
        {
          $BuildNoFile = $VersionInfoFile;
        }
      else
        {
          my $NeoBuildNoFile = "$drive/topclass/neo/sources/buildno.h";
          if ( -e $NeoBuildNoFile )
            {
              $BuildNoFile = $NeoBuildNoFile;
            }
          else
            {
              my $VersionInfoFile = "$drive/topclass/neo/sources/versioninfo.h";
              if ( -e $VersionInfoFile )
                {
                  $BuildNoFile = $VersionInfoFile;
                }
            }
        }
    }
  print "$BuildNoFile\n";

  if ( !open (BUILDNO, $BuildNoFile) )
    {
      print "**** Cannot open file $BuildNoFile for reading\n";
      return;
    }

  while ( <BUILDNO> )
    {
      if ( /\#define BUILDNUMBER +([0-9]+)/ )
        {
          $Build = $1;
          #$Build++;
          #$Build--;
        }
      elsif ( /\#define MAJORREVISION +([0-9]+)/ )
        {
          $Major = $1;
        }
      elsif ( /\#define MINORREVISION +([0-9]+)/ )
        {
          $Minor = $1;
        }
      elsif ( /\#define POINTREVISION +([0-9]+)/ )
        {
          $Point = $1;
        }
    }
  close BUILDNO;
  if ( $Build % 2 == 1 )
    {
      $Build--;
    }
  if ( $Build < 0 )
    {
    }
  elsif ( $Build < 10 )
    {
      $Build = "00" . $Build;
    }
  elsif ( $Build < 100 )
    {
      $Build = "0" . $Build;
    }
}

sub CopyExes()
  {
    my $distrib = "$Builds\\TopClassV${Major}.${Minor}.${Point}\\builds\\build${Build}";
    if ( -d $distrib )
      {
  runCmd( "xcopy /y /i /d $distrib\\windows\\webable\\*.dll $nonwebroot\\" );
  runCmd( "xcopy /y /i /d $distrib\\windows\\webable\\*.jar $nonwebroot\\" );

       #runCmd( "xcopy /y /i /d $distrib\\Executables\\www\\*.* $$nonwebroot\\" );
  runCmd( "xcopy /y /i /d $distrib\\Executables\\www\\tce*ud.exe $nonwebroot\\" );
  runCmd( "xcopy /y /i /d $distrib\\Executables\\www\\tce*iis.dll $nonwebroot\\" );
  runCmd( "xcopy /y /i /d $distrib\\windows\\nonwebable\\*.dll $nonwebroot\\" );
  runCmd( "xcopy /y /i /d $distrib\\windows\\nonwebable\\cpi\\*.dll $nonwebroot\\cpi\\" );
  runCmd( "xcopy /y /i /d $distrib\\windows\\nonwebable\\qpi\\*.dll $nonwebroot\\qpi\\" );
  runCmd( "xcopy /y /i /d $distrib\\windows\\nonwebable\\spi\\*.dll $nonwebroot\\spi\\" );
  runCmd( "xcopy /y /i /d $distrib\\windows\\nonwebable\\language\\*english.lang $nonwebroot\\language\\" );
  runCmd( "xcopy /y /i /d $distrib\\windows\\nonwebable\\language\\*.labels $nonwebroot\\language\\" );
      }
    else
      {
  print "Build directory not found $distrib\n";
      }
  }

sub runCmd( $% )
  {
    my ( $cmd, @filters ) = @_;

    print "$cmd\n";
    if ( $testing eq "Y" )
      {
        return;
      }
    if ( open( CMD, "$cmd |" ) )
      {
        while (<CMD>)
          {
            my $line = $_;
            if ( $line =~ /^$/ )
              {
              }
            else
              {
                my $matched = 0;
                foreach my $filter ( @filters )
                  {
                    if ( $line =~ /$filter/ )
                      {
                        $matched = 1;
                        last;
                      }
                  }
                if ( $matched eq 0 )
                  {
                    print "$_";
                  }
              }
          }
      }
  }


GetBuildNumber( "" );
CopyExes()
