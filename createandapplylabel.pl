# createandapplylabel.pl

#use strict;

sub CreateAndApplyNewLabel($$$$@)
{
  my ($Ctool, $ViewDriveName, $LabelName, $CurrentBuildNoStr, @VobList) = @_;
  my $CurrentVob = "";

  for $CurrentVob (@VobList)
    {
      chdir ("$ViewDriveName$CurrentVob") or die "Cannot chdir to $ViewDriveName$CurrentVob\n" ;
      print "\nCreating label....\n";
      print "$Ctool mklbtype -comment \"TopClass Server Build \" $LabelName\n";
      system ("$Ctool mklbtype -comment \"TopClass Server Build $CurrentBuildNoStr\" $LabelName");

      print "Applying label $LabelName to $ViewDriveName$CurrentVob.....(this may take a few minutes) \n";
      print "$Ctool mklabel -replace -recurse $LabelName .\n";
      system ("$Ctool mklabel -replace -recurse $LabelName .");
    }
}


my @VobList           = ("\\topclass", "\\3rdparty", "\\utils", "\\authoring");
my $Ctool             = "cleartool";

my $Major             = "7";
my $Minor             = "1";
my $Point             = "5";
my $Build             = "154";

my $ViewDriveName     = "y:";
my $LabelName         = "TC_$Major$Minor$Point" . "_BUILD_$Build";
my $CurrentBuildNoStr = "TopClass Server $Major.$Minor.$Point Build $Build";

#CreateAndApplyNewLabel($Ctool, $ViewDriveName, $LabelName, $CurrentBuildNoStr, @VobList);

CreateAndApplyNewLabel( $Ctool, $ViewDriveName, $LabelName, $CurrentBuildNoStr, @VobList );
