use strict;

my $major = 8;
my $minor = 1;
my $point = 0;
my $build = "054";
my $product = "TopClass";
my $company = "WBT Systems";
my $rootFolder = "C:\\Installer_Files";
my $outputFolder = "$rootFolder\\Output";
my $sourceFolder = "$rootFolder\\build${build}";

my %folders;
my %counters;
my @components;

sub projectSettings() {
print MSIOUT "<ProjectSettings>\n";
print MSIOUT "<ProjectType>installer</ProjectType>\n";
print MSIOUT "<ProductName>${product} ${major}.${minor}</ProductName>\n";
print MSIOUT "<ProductVersion>${major}.${minor}.${point}</ProductVersion>\n";
print MSIOUT "<ProductManufacturer>${company}</ProductManufacturer>\n";
print MSIOUT "<ProductID>4551018D-CD58-4372-937F-B38512D223F3</ProductID>\n";
print MSIOUT "<UpgradeID>E692E5B4-3E9C-4A67-A47D-2295FCA99300</UpgradeID>\n";
print MSIOUT "<MergeModuleIgnoreTables/>\n";
print MSIOUT "<Package Id=\"\" Description=\"${product} ${major}.${minor}\" Manufacturer=\"${company}\" Comments=\"Package Comments\" InstallerVersion=\"3.0\" Platforms=\"\" Keywords=\"\" ReadOnly=\"no\" Compressed=\"yes\" AdminImage=\"no\" ShortNames=\"no\" LanguageNeutral=\"yes\" InstallPrivileges=\"elevated\"/>\n";
print MSIOUT "<ControlPanelSettings NoRepair=\"no\" NoRemove=\"no\" NoModify=\"yes\" SystemComponent=\"no\">\n";
print MSIOUT "<AboutInfoUrl/>\n";
print MSIOUT "<ContactInfo/>\n";
print MSIOUT "<HelpUrl/>\n";
print MSIOUT "<HelpTelephone/>\n";
print MSIOUT "<UpdateInfoUrl/>\n";
print MSIOUT "<Size/>\n";
print MSIOUT "<ReadmePath/>\n";
print MSIOUT "<Comments/>\n";
print MSIOUT "<IconPath/>\n";
print MSIOUT "</ControlPanelSettings>\n";
print MSIOUT "<Property Id=\"ALLUSERS\" Value=\"1\" Admin=\"no\" Hidden=\"no\" Secure=\"no\" SuppressModularization=\"no\"/>\n";
print MSIOUT "<Property Id=\"MSIFACTUIRMOption\" Value=\"UseRM\" Admin=\"no\" Hidden=\"no\" Secure=\"no\" SuppressModularization=\"no\"/>\n";
print MSIOUT "<Property Id=\"MSIFACT_INSTALLDIR\" Value=\"INSTALLDIR\" Admin=\"no\" Hidden=\"no\" Secure=\"no\" SuppressModularization=\"no\"/>\n";
print MSIOUT "<UpgradeCodes/>\n";
print MSIOUT "</ProjectSettings>\n";
}

sub buildSettings() {
print MSIOUT "<BuildSettings Delimiter=\";\" LastSelectedBuildStep=\"Before Build\">\n";
print MSIOUT "<OutputFolder>${outputFolder}</OutputFolder>\n";
print MSIOUT "<OutputFilenameRoot>TC${major}${minor}${point}b${build}</OutputFilenameRoot>\n";
print MSIOUT "<WorkingFolder>${outputFolder}</WorkingFolder>\n";
print MSIOUT "<CompileSeparately>yes</CompileSeparately>\n";
print MSIOUT "<RemoveOrphanedFolders>no</RemoveOrphanedFolders>\n";
print MSIOUT "<VerboseCandle>yes</VerboseCandle>\n";
print MSIOUT "<VerboseLight>yes</VerboseLight>\n";
print MSIOUT "<ContinueAfterValidationErrors>no</ContinueAfterValidationErrors>\n";
print MSIOUT "<CompilerOptions/>\n";
print MSIOUT "<LinkerOptions/>\n";
print MSIOUT "<AskLanguage>yes</AskLanguage>\n";
print MSIOUT "<BuildLanguage/>\n";
print MSIOUT "<FilesToCompile CaseSensitive=\"no\" Template=\"%s_%d\"/>\n";
print MSIOUT "<FilesToLink CaseSensitive=\"no\" Template=\"%s_%d\"/>\n";
print MSIOUT "<LocalizationFiles CaseSensitive=\"no\" Template=\"%s_%d\"/>\n";
print MSIOUT "<BuildBootstrapData BootstrapMethod=\"0\">\n";
print MSIOUT "<CustomConfigFile/>\n";
print MSIOUT "<CustomExtraCmdLine/>\n";
print MSIOUT "<MSIIncludeMode>embedded</MSIIncludeMode>\n";
print MSIOUT "<MSIDownloadURL>http://www.website.com/setup.msi</MSIDownloadURL>\n";
print MSIOUT "<AllowMSIExtractCmdLine>yes</AllowMSIExtractCmdLine>\n";
print MSIOUT "<VistaExecutionLevel>requireAdministrator</VistaExecutionLevel>\n";
print MSIOUT "<UseCustomIcon>no</UseCustomIcon>\n";
print MSIOUT "<IconPath/>\n";
print MSIOUT "<StampExecutable>no</StampExecutable>\n";
print MSIOUT "<FileVersion/>\n";
print MSIOUT "<ProductVersion/>\n";
print MSIOUT "<CompanyName/>\n";
print MSIOUT "<ProductName/>\n";
print MSIOUT "<InternalName/>\n";
print MSIOUT "<FileDescription/>\n";
print MSIOUT "<Copyright/>\n";
print MSIOUT "<Trademarks/>\n";
print MSIOUT "<PrivateBuild/>\n";
print MSIOUT "<SpecialBuild/>\n";
print MSIOUT "<Comments/>\n";
print MSIOUT "<Dependencies/>\n";
print MSIOUT "<BootstrapLanguages>\n";
print MSIOUT "<BootstrapLanguage Name=\"English-US\" LCIDList=\"1033,2057,3081,10249,4105,9225,6153,8201,5129,13321,7177,11273\" SourceFile=\"Data\\Languages\\English.xml\" DefaultLanguage=\"yes\"/>\n";
print MSIOUT "</BootstrapLanguages>\n";
print MSIOUT "</BuildBootstrapData>\n";
print MSIOUT "<Fragments>\n";
print MSIOUT "<FragmentInclude SourceFile=\"\$(var.MSIFactoryFolder)\\UI\\Default\\Common.wxs\" CopyToOutputFolder=\"yes\">\n";
print MSIOUT "<Insertions>\n";
print MSIOUT "<Insertion InsertType=\"1\">\n";
print MSIOUT "<TargetXMLPath>/Wix/Product</TargetXMLPath>\n";
print MSIOUT "<TextToInsert><![CDATA[<UIRef Id=\"SUFWIUI_Common\" />]]></TextToInsert>\n";
print MSIOUT "</Insertion>\n";
print MSIOUT "</Insertions>\n";
print MSIOUT "</FragmentInclude>\n";
print MSIOUT "<FragmentInclude SourceFile=\"\$(var.MSIFactoryFolder)\\UI\\Default\\ErrorText.wxs\" CopyToOutputFolder=\"yes\">\n";
print MSIOUT "<Insertions>\n";
print MSIOUT "<Insertion InsertType=\"1\">\n";
print MSIOUT "<TargetXMLPath>/Wix/Product</TargetXMLPath>\n";
print MSIOUT "<TextToInsert><![CDATA[<UIRef Id=\"SUFUI_ErrorText\" />]]></TextToInsert>\n";
print MSIOUT "</Insertion>\n";
print MSIOUT "</Insertions>\n";
print MSIOUT "</FragmentInclude>\n";
print MSIOUT "<FragmentInclude SourceFile=\"\$(var.MSIFactoryFolder)\\UI\\Default\\ProgressText.wxs\" CopyToOutputFolder=\"yes\">\n";
print MSIOUT "<Insertions>\n";
print MSIOUT "<Insertion InsertType=\"1\">\n";
print MSIOUT "<TargetXMLPath>/Wix/Product</TargetXMLPath>\n";
print MSIOUT "<TextToInsert><![CDATA[<UIRef Id=\"SUFUI_ProgressText\" />]]></TextToInsert>\n";
print MSIOUT "</Insertion>\n";
print MSIOUT "</Insertions>\n";
print MSIOUT "</FragmentInclude>\n";
print MSIOUT "</Fragments>\n";
print MSIOUT "<CodeSignData>\n";
print MSIOUT "<Location/>\n";
print MSIOUT "<SPCFile/>\n";
print MSIOUT "<PVKFile/>\n";
print MSIOUT "<TimeStampURL/>\n";
print MSIOUT "<Description/>\n";
print MSIOUT "<DescriptionURL/>\n";
print MSIOUT "<CodeSignSetups>no</CodeSignSetups>\n";
print MSIOUT "<CodeSigningTool>0</CodeSigningTool>\n";
print MSIOUT "<Arguments/>\n";
print MSIOUT "</CodeSignData>\n";
print MSIOUT "<Define Name=\"SourceFolder\" Value=\"${sourceFolder}\"/>\n";
print MSIOUT "<FileToRunBeforeBuild File=\"\" Args=\"\" WaitForReturn=\"no\"/>\n";
print MSIOUT "<FileToRunBeforeCompile File=\"\" Args=\"\" WaitForReturn=\"no\"/>\n";
print MSIOUT "<FileToRunAfterBuild File=\"\" Args=\"\" WaitForReturn=\"no\"/>\n";
print MSIOUT "</BuildSettings>\n";
}

sub gatherFolders($$;$) {
  my ($path, $name, $id) = @_;
  #print "outputFolder(@_)\n";
  my $dh;
  my $dir;

  if ( $path =~ /\\$/ ) {
    $dir = "$path$name\\";
  }
  elsif ( $path ) {
    $dir = "$path\\$name\\";
  }
  else {
    $dir = "$name\\";
  }
  # need to add this folder.
  my $fname = $name;

  $fname = $id if ( $id );
  $fname =~ s!-!!g; # get rid of hyphens
  if ( $fname =~ /^[A-Z0-9]+$/ ) {
    $fname = "Folder" . $fname;
  }
  my $count = $counters{$fname};
  #print "Looking for \$counters{$fname} => $count\n";
  if ( $count ) {
    # name already in use
    $count++;
    $counters{$fname} = $count;
    $folders{$dir} = sprintf( "%s_%04d", $fname, $count );
  }
  else {
    $counters{$fname} = 1;
    $folders{$dir} = $fname;
  }
  if ( opendir( $dh, $dir ) ) {
    my $file;
    while ( defined( $file = readdir($dh) ) ) {
      my $full = "$dir$file";
      #print "$full\n";
      if ( $file eq "." or $file eq ".." ) {
      }
      elsif ( -d $full ) {
        gatherFolders($dir, $file);
      }
    }
    closedir($dh);
  }
}

sub outputFolder($$) {
  my ($path, $name) = @_;
  #print "outputFolder(@_)\n";
  my $dh;
  my $dir;
  if ( $path =~ /\\$/ ) {
    $dir = "$path$name\\";
  }
  elsif ( $path ) {
    $dir = "$path\\$name\\";
  }
  else {
    $dir = "$name\\";
  }
  my $id = $folders{$dir};
  if ( opendir( $dh, $dir ) ) {
    my $subdirs;
    my $file;
    while ( defined( $file = readdir($dh) ) ) {
      my $full = "$dir$file";
      #print "$full\n";
      if ( $file eq "." or $file eq ".." ) {
      }
      elsif ( -d $full ) {
        if ( !$subdirs ) {
          print MSIOUT "<Folder Name=\"$name\" Id=\"$id\">\n";
          $subdirs = 1;
        }
        outputFolder($dir, $file);
      }
    }
    closedir($dh);
    if ( !$subdirs ) {
      print MSIOUT "<Folder Name=\"$name\" Id=\"$id\"/>\n";
    }
    else {
      print MSIOUT "</Folder>\n";
    }
  }
}

sub outputFiles($$) {
  my ($path, $name) = @_;
  #print "outputFolder(@_)\n";
  my $dh;
  my $dir;
  if ( $path =~ /\\$/ ) {
    $dir = "$path$name\\";
  }
  elsif ( $path ) {
    $dir = "$path\\$name\\";
  }
  else {
    $dir = "$name\\";
  }
  my $id = $folders{$dir};
  if ( opendir( $dh, $dir ) ) {
    my $file;
    while ( defined( $file = readdir($dh) ) ) {
      my $full = "$dir$file";
      #print "$full\n";
      if ( $file eq "." or $file eq ".." ) {
      }
      elsif ( -d $full ) {
        outputFiles($dir, $file);
      }
      else {
        setupComponentFile($dir, $file);
      }
    }
    closedir($dh);
  }
}

sub setupComponentFile($$) {
my ($path,$file) = @_;
my $componentGuid = "guid";
my $userProfileGuid = "guid";
my $desc = $file;
$desc =~ s!\..+!!;
# TODO get descrition from .exe / .dll
my $folder = $folders{$path};
my $id = $file;
$id =~ s! !!g;
if ( length($id) gt 30 ) {
  $id = substr($id, 0, 30);
}
@components = (@components, $id);
my $comreg = 0;
if ( $file eq "cruflwbt.dll" or $file eq "TopClassDB.dll" ) {
  $comreg = 1;
}

print MSIOUT "<SetupComponent ID=\"$id\" GUID=\"${componentGuid}\" DisableRegReflection=\"no\" Transitive=\"no\" Win64=\"no\" Location=\"0\" NeverOverwrite=\"no\" NeverRemove=\"no\" SharedSystem=\"no\" ComponentDirIsKeyPath=\"no\">\n";
print MSIOUT "<Condition/>\n";
print MSIOUT "<FileList>\n";
print MSIOUT "<SetupItem Type=\"1\" ID=\"$id\" ComponentID=\"$id\" Vital=\"no\" KeyPath=\"no\" IsCompanionFile=\"no\" CompanionFile=\"\">\n";
print MSIOUT "<Filename>${file}</Filename>\n";
print MSIOUT "<LocalFolder>${path}</LocalFolder>\n";
print MSIOUT "<DestinationFolder>${folder}</DestinationFolder>\n";
print MSIOUT "<DestinationFilename/>\n";
print MSIOUT "<OriginalAttributes>yes</OriginalAttributes>\n";
print MSIOUT "<NewFileAttributes>0</NewFileAttributes>\n";
print MSIOUT "<VersionData/>\n";
print MSIOUT "<ShortcutData>\n";
print MSIOUT "<Description>$desc</Description>\n";
print MSIOUT "<Comment/>\n";
print MSIOUT "<WorkingFolder IsProperty=\"no\"/>\n";
print MSIOUT "<CommandLineArguments/>\n";
print MSIOUT "<Advertised>no</Advertised>\n";
print MSIOUT "<HotKey>0</HotKey>\n";
print MSIOUT "<RunMode>0</RunMode>\n";
print MSIOUT "<IconMode>0</IconMode>\n";
print MSIOUT "<IconIndex>0</IconIndex>\n";
print MSIOUT "<IconFile/>\n";
print MSIOUT "<UserProfileComponentId/>\n";
print MSIOUT "<UserProfileComponentGuid>${userProfileGuid}</UserProfileComponentGuid>\n";
print MSIOUT "<CustomLocation/>\n";
print MSIOUT "<Shortcuts/>\n";
print MSIOUT "</ShortcutData>\n";
print MSIOUT "<Registration COM=\"$comreg\" RegTTF=\"no\" OverrideFontName=\"no\" TTFName=\"\" MediaSource=\"1\">\n";
print MSIOUT "<FileAssociations/>\n";
print MSIOUT "<ProgIDs/>\n";
print MSIOUT "<COMClasses/>\n";
print MSIOUT "<AppIDs/>\n";
print MSIOUT "<TypeLibs/>\n";
print MSIOUT "<Assembly Type=\"no\"/>\n";
print MSIOUT "<UserPerimssions/>\n";
print MSIOUT "</Registration>\n";
print MSIOUT "</SetupItem>\n";
print MSIOUT "</FileList>\n";
print MSIOUT "<RegistryList/>\n";
print MSIOUT "<INIFileList/>\n";
print MSIOUT "<ShortcutList/>\n";
print MSIOUT "<FileOpList/>\n";
print MSIOUT "<EnvironmentVarList/>\n";
print MSIOUT "<ServiceList/>\n";
print MSIOUT "<ODBCList/>\n";
print MSIOUT "<XMLList/>\n";
print MSIOUT "<IISList/>\n";
print MSIOUT "<ReserveCostList/>\n";
print MSIOUT "<IsolateComponentList/>\n";
print MSIOUT "</SetupComponent>\n";
}

sub destinationFolders() {
gatherFolders($sourceFolder, "TopClass Server", "nonwebable");
gatherFolders($sourceFolder, "tcc");
gatherFolders($sourceFolder, "topclass", "webable" );
print MSIOUT "<DestinationFolders>\n";
print MSIOUT "<Folder Name=\"SourceDir\" Id=\"TARGETDIR\">\n";
print MSIOUT "<Folder Name=\"TopClass8\" Id=\"INSTALLDIR\">\n";
outputFolder($sourceFolder, "TopClass Server");
outputFolder($sourceFolder, "tcc");
outputFolder($sourceFolder, "topclass");
print MSIOUT "<Folder Name=\"[AppDataFolder]\" Id=\"AppDataFolder\"/>\n";
print MSIOUT "<Folder Name=\"[DesktopFolder]\" Id=\"DesktopFolder\"/>\n";
print MSIOUT "<Folder Name=\"[FontsFolder]\" Id=\"FontsFolder\"/>\n";
print MSIOUT "<Folder Name=\"[ProgramFilesFolder]\" Id=\"ProgramFilesFolder\"/>\n";
print MSIOUT "<Folder Name=\"[ProgramMenuFolder]\" Id=\"ProgramMenuFolder\">\n";
print MSIOUT "<Folder Name=\"My Product\" Id=\"StartMenuAppFolder\"/>\n";
print MSIOUT "</Folder>\n";
print MSIOUT "<Folder Name=\"[SystemFolder]\" Id=\"SystemFolder\"/>\n";
print MSIOUT "<Folder Name=\"[WindowsFolder]\" Id=\"WindowsFolder\"/>\n";
print MSIOUT "</Folder>\n";
print MSIOUT "</DestinationFolders>\n";
}

sub otherComponents() {
if ( open( OTHER, "othercomponents.inc" ) ) {
  while ( <OTHER> ) {
    print MSIOUT;
  }
  close( OTHER );
}
}

sub fileComponents() {
outputFiles($sourceFolder, "TopClass Server");
outputFiles($sourceFolder, "tcc");
outputFiles($sourceFolder, "topclass");
setupComponentFile("$sourceFolder\\", "TCDB${major}${minor}${point}MSSQLb${build}.exe");
setupComponentFile("$sourceFolder\\", "TCDB${major}${minor}${point}Oracleb${build}.exe");
setupComponentFile("$sourceFolder\\", "vcredist_x86.exe");
}

sub setupComponents() {
print MSIOUT "<SetupItemManager>\n";
print MSIOUT "<BaseDirectory>$sourceFolder</BaseDirectory>\n";
print MSIOUT "<ComponentList>\n";
otherComponents();
fileComponents();
print MSIOUT "</ComponentList>\n";
print MSIOUT "</SetupItemManager>\n";
}

sub uiData() {
if ( open( OTHER, "uidata.inc" ) ) {
  while ( <OTHER> ) {
    print MSIOUT;
  }
  close( OTHER );
}
}

sub listComponents() {
print MSIOUT "<ComponentID>CreateIISVirtualDir_0001</ComponentID>\n";
print MSIOUT "<ComponentID>CreateIISVirtualDir_0002</ComponentID>\n";
foreach ( @components ) {
print MSIOUT "<ComponentID>$_</ComponentID>\n";
}
}

sub features() {
print MSIOUT "<Features DefaultFeature=\"Complete\">\n";
print MSIOUT "<Feature>\n";
print MSIOUT "<ID>Complete</ID>\n";
print MSIOUT "<ParentFeatureID/>\n";
print MSIOUT "<Title>Complete</Title>\n";
print MSIOUT "<Description>Complete program features.</Description>\n";
print MSIOUT "<AllowAbsent>yes</AllowAbsent>\n";
print MSIOUT "<AllowAdvertise>no</AllowAdvertise>\n";
print MSIOUT "<AdvertiseOnlyIfSupported>yes</AdvertiseOnlyIfSupported>\n";
print MSIOUT "<AdvertiseIsDefaultState>no</AdvertiseIsDefaultState>\n";
print MSIOUT "<EnableBrowseForFolder>no</EnableBrowseForFolder>\n";
print MSIOUT "<ConfigurableDirectory/>\n";
print MSIOUT "<InitialDisplayState>0</InitialDisplayState>\n";
print MSIOUT "<InstallDefault>1</InstallDefault>\n";
print MSIOUT "<Level>1</Level>\n";
print MSIOUT "<Conditions/>\n";
print MSIOUT "<Components>\n";
listComponents();
print MSIOUT "</Components>\n";
print MSIOUT "<MergeModules>\n";
print MSIOUT "<MergeModuleID>CRT</MergeModuleID>\n";
print MSIOUT "<MergeModuleID>CRT.Policy</MergeModuleID>\n";
print MSIOUT "</MergeModules>\n";
print MSIOUT "</Feature>\n";
print MSIOUT "</Features>\n";
print MSIOUT "<MergeModules>\n";
print MSIOUT "<MergeModule ID=\"CRT\" DiskID=\"1\" FileCompression=\"no\" SourceFile=\"$rootFolder\\Microsoft_VC80_CRT_x86.msm\" Directory=\"INSTALLDIR\" InheritLCID=\"yes\" LanguageID=\"\"/>\n";
print MSIOUT "<MergeModule ID=\"CRT.Policy\" DiskID=\"1\" FileCompression=\"no\" SourceFile=\"$rootFolder\\policy_8_0_Microsoft_VC80_CRT_x86.msm\" Directory=\"INSTALLDIR\" InheritLCID=\"yes\" LanguageID=\"\"/>\n";
print MSIOUT "</MergeModules>\n";
}

sub finally() {
print MSIOUT "<LaunchConditions>\n";
print MSIOUT "<OSConditions>\n";
print MSIOUT "<array_item>32768</array_item>\n";
print MSIOUT "<array_item>0</array_item>\n";
print MSIOUT "<array_item>0</array_item>\n";
print MSIOUT "<array_item>65535</array_item>\n";
print MSIOUT "<array_item>65535</array_item>\n";
print MSIOUT "<array_item>65535</array_item>\n";
print MSIOUT "<array_item>65535</array_item>\n";
print MSIOUT "<array_item>65535</array_item>\n";
print MSIOUT "</OSConditions>\n";
print MSIOUT "<RAM>0</RAM>\n";
print MSIOUT "<ScreenWidth>0</ScreenWidth>\n";
print MSIOUT "<ScreenHeight>0</ScreenHeight>\n";
print MSIOUT "<ColorDepth>0</ColorDepth>\n";
print MSIOUT "<WIVersion/>\n";
print MSIOUT "<CustomLaunchConditions/>\n";
print MSIOUT "</LaunchConditions>\n";
print MSIOUT "<SearchProperties/>\n";
print MSIOUT "<CustomActions/>\n";
print MSIOUT "<MediaItems>\n";
print MSIOUT "<MediaItem ID=\"1\" DiskPrompt=\"Disk 1\" Type=\"0\" CompressionLevel=\"3\" EmbedCabInMSI=\"yes\" CabFilename=\"setup.cab\" OutputSubFolder=\"\" VolumeLabel=\"\"/>\n";
print MSIOUT "</MediaItems>\n";
}

die "invalid sourceFolder $sourceFolder\n" unless ( -e $sourceFolder );

open( MSIOUT, ">tc${major}${minor}${point}.msifact" ) or die;

print MSIOUT "<SUFWIProject FileVersion=\"2.1.1005.0\">\n";

projectSettings();
buildSettings();
destinationFolders();
setupComponents();
uiData();
features();
finally();

print MSIOUT "</SUFWIProject>\n";

close( MSIOUT );


