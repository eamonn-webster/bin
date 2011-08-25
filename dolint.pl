#
#  File: dolint.pl
#  Author: eweb
#

#
# Call devbuild with the appropriate parameters...
#
#

my $localDrive = "c:";
my $ccDrive = $ARGV[0];
my $Major = "";
my $Minor = "";
my $Point = "";
my $Build = "";
my $Installers = "N";
my $CopyFiles  = "N";
my $UseClearcase = "N";
my $DoLint = "Y";
my $SendTo = "$ENV{USERNAME}\@wbtsystems.com";
my $DebugBuild = "Y";

unless ( -d "$localDrive\\" )
  {
    die "Local drive $localDrive doesn't exist\n";
  }

if ( $ccDrive eq "" or ! -d "$ccDrive\\" )
  {
    die "Clearcase drive $ccDrive doesn't exist\n";
  }

##die "$SendTo\n";

# change to the local dir.

unless ( -d "$localDrive\\autodevbuild" )
  {
    mkdir( "$localDrive\\autodevbuild" );
  }

chdir( "$localDrive\\autodevbuild" );

system( "$ccDrive\\utils\\autodevbuild\\setup $ccDrive");

#Options : -i increment the build number in buildno.h file
#        : -q [Y] quick build configurations in dosanddonts.txt
#        : -b the build number for this build.
#        : -c compare this build against the previous build for missing files etc.
#        : -m major release version no.
#        : -n minor release version no.
#        : -p point release version no.
#        : -j build java
#
#        : -t testing
#        : -C [Y] build c++? (Y/N)
#        : -P [Y] build Publisher? (Y/N)
#        : -I [Y] build Installers? (Y/N)
#        : -F [Y] copy files? (Y/N)
#        : -T [production@wbtsystems.com] who to mail
#        : -B [H:] builds drive e.g. net use for \\elm\builds
#        : -H [hogfather] Host name for URL
#        : -S [AutoBuild] webable directory on host for URL
#        : -Q [N] Roman's SQl Server script
#        : -U [Y] Use clearcase
#        : -D [DosAndDonts.txt] DosAndDonts file
#        : -L [N] Lint topclass...
#        : -K [Y] Spell Check
#        : -G [N] Debug Build


sub GetBuildNumber()
{
  my $BuildNoFile = "$ccDrive/topclass/oracle/topclass/sources/buildno.h";

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
}

GetBuildNumber();

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

my $cmd = "perl devbuild.pl -d $ccDrive -m $Major -n $Minor -p $Point -b $Build -B $localDrive -T $SendTo -I $Installers -F $CopyFiles -U $UseClearcase -K N -L $DoLint -G $DebugBuild -C N -P N";
print "$cmd\n";
system( $cmd );
