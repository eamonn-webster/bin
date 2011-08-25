#!/usr/bin/perl

###### Properties
# Filename : Getlabel.pl
# Created By: Frank Kavanagh
# Date Created: 12th September 2008
# 
# Contents: Retrieves contents of VOBs based on a LABEL and user


###### VERSION CHANGE HISTORY
#
# Version       Date            User      Reason
# 1.0           12 Sep 2008     fkav      Initial code
# 1.1			12 Jun 2009     fkav      Wrote header to release notes, Removed code from MkDir
# 1.2           29 Jul 2009     jroche    #00008 tidied up the format and ready to add to CC
# 1.3			23 Dec 2009     fkav      #00008 labelled directories - No not copy as files,Allow for a specified user
# 1.4			03 Jun 2010     fkav      #00008 Search for user as 'created_by'
#



my $g_K_intCurrentVersion = "V1.4";


######

# Package includes...
#

#
use strict;
use File::Temp;
use File::Copy; 
use File::Basename;
use File::CheckTree;


my $g_label = "";
my $g_drive = "";
my $g_voblist = "";
my $g_user = "";
my $g_releasePath = "";
my $g_createFolderStructure = 0;
my $g_displayHelp = 0;
my $commandLine = "";
my $result= 0;


# get the command line variables
getCommandLine($#ARGV, @ARGV);
  
# Validate mandatory parameters and check if help requested
if ($g_label eq "" || $g_drive eq "" || $g_voblist eq "" || $g_displayHelp){

    writeUsage();
    die "... END ...\n\n"
  }


# TODO - Function to verify and correct arguments (uppercase label, add : to drive if not there, forward slashes for path etc)
# TODO - Read file list and copy files rather than using clearcase copy as this loses the folder structure
# TODO - Logging
# TODO - Proper error handling
# TODO - Load config file to create a repackaged zip file mapping Clearcase folders to release folders
# TODO - Create release build files (compile java, create XMl for template load, add prefs to Topclass XML)
# TODO - Build install script (or add flag here to either build release file or install files.)
#     - Would have to map build folder structure to Server folder structure per environment (multiple config files)
#     - Connect to TopClass to back up current + load updated XML
#       - Backup existing files
#     - Connect to DB and execute SQL (this will cause a problem if there are dependencies in the order of running the scripts)
#     - Copy required files
#     - Full logging + auditing
#     - Services restart
#     - Auto update a default template with info from release


print "Running GetLabel with the parameters:\nLabel = " .$g_label . "\nDrive = " . $g_drive . "\nVOBlist = " . $g_voblist . "\n" . $g_user . "\nCopy path = " . $g_releasePath ."\n\n";


# FIND FILES + BUILD LIST
findFiles() || die "Error retrieving file list";
  


# GET FILES IF PATH PROVIDED
if ($g_releasePath ne ""){
	if (!getFiles()){

        die "Error getting files";

      }
  }
else{
    print "Skipping file copy... no copy path provided.\n";
  }


print "Processing complete \n";

########################################################################
# Method:     getCommandLine
# Function:   Parses the command line
# Inputs:     1) The number of command line arguments
#       2) The argument array
# Outputs:    none
# Return:     0/1 (0 if failed, 1 if successful)
# Notes:      
########################################################################
sub getCommandLine
  {
    # function parameters
    my $NumArgs = shift;
    my @ARGS = @_;

    # Args is 0-based, so increment to get 1 based
    $NumArgs++;

    # Process the arguments list only if there are arguments
    if ($NumArgs > 0)
      {
        my $arg;
        foreach $arg (@ARGS)
          {
            # Mandatory Command Line Parameters
            if ($arg =~ /^-label=(.*)/i)    
              {
                $g_label = $1;
              }
            elsif ($arg =~ /^-drive=(.*)/i) 
              { 
                $g_drive = $1; 
              }
            elsif ($arg =~ /^-voblist=(.*)/i)   
              { 
                $g_voblist = $1; 
              }
            # Optional Command Line Parameters
			elsif ($arg =~ /^-user=(.*)/i)	
			{ 
			   if($1 ne "") {$g_user = " && created_by(" . $1 . ")";}
			}
            elsif ($arg =~ /^-copyto=(.*)/i)  
              { 
                $g_releasePath = $1; 
              }
            elsif ($arg =~ /^-cf/i)     
              { 
                $g_createFolderStructure = 1;
              }
            elsif ($arg =~ /^-help/i)     
              { 
                $g_displayHelp = 1;
              }
            else
              {
                print "Unknown Argument $arg.\n";
              }
          }
      } 
}

########################################################################
# Method:     findFiles
# Function:   finds files and builds list
# Inputs:     none
# Outputs:    none
# Return:     0/1 (0 if failed, 1 if successful)
# Notes:      
########################################################################
sub findFiles
  {

    # get array of VOBs
    my @VOBLIST = split(/,/, $g_voblist);

    my $vob = "";

	# Write Release Notes Header
	open (RELEASEFILE, ">" . $g_releasePath ."/Release_Notes.txt");
	print RELEASEFILE "\n\nRELEASE LABEL: $g_label\n\nFiles Released:\n---------------\n";
	close (RELEASEFILE);
        
	foreach $vob (@VOBLIST){
        print "Searching for: $g_label on '$vob' VOB\n\n";

        print "Building file list...\n";
        
        if($g_user eq "") {
		  $commandLine ="cleartool find \\$vob -element \"{lbtype_sub($g_label)}\" -print >> $g_releasePath/Release_Notes.txt ";
        }
        else{
          $commandLine ="cleartool find \\$vob -version \"{lbtype($g_label) $g_user }\" -print >> $g_releasePath/Release_Notes.txt ";
        } 
        
        $result=system($commandLine);

				
		$commandLine ="cleartool find \\$vob -version \"{lbtype($g_label) $g_user }\" -print >> $g_releasePath/FileVersions.txt ";

        $result=system($commandLine);

		if ($result != 0){

            print "result of $commandLine = $result.\n";
            return 0;
          }   
        print "File list for '$vob' vob built.\n\n";

      }

	# Write Release Notes Footer
	open (RELEASEFILE, ">>" . $g_releasePath ."/Release_Notes.txt");
	print RELEASEFILE "\n\n\nIssues Fixed:\n-------------\n\n\n\nRelease Steps:\n--------------\n";
	close (RELEASEFILE);

    return 1;

  }

########################################################################
# Method:     getFiles
# Function:   finds files and copies to location
# Inputs:     none
# Outputs:    none
# Return:     0/1 (0 if failed, 1 if successful)
# Notes:      
########################################################################
sub getFiles
  {

    my $line    = "";
    my $directory    = "";
    my $dirVersion    = "";
    my $Destination    = "";

    #TEMP FIX
    open(FILELIST, "<" . $g_releasePath ."/FileVersions.txt");

    print "Copying files...\n";

	while ($line = <FILELIST>){



        $dirVersion = $line;

        #Remove carraige return
        $dirVersion =~ s/\r|\n//g;


        $line =~ m/(.*)@@(.*)/i;
        $directory = $1;



        my($FileName, $path, $suffix) = fileparse($g_releasePath . $directory);

        #Check to see if we are to create the folder structure
		if ($g_createFolderStructure){

			if(! -d $path){
            MkDir($path);
			}


            $Destination = $path; 

		}else{
            $Destination = $g_releasePath . "\\";
          }

		if ($FileName =~ m/(.*)\.(.*)/i) {
		  $suffix  = $2;
		}
		  
		
		print "    filename = $FileName, type = $suffix...\n";

        # Build command line
		
		#Allow for labelled directories... if no file suffix then do not copy
		if ($suffix){
		   
		    if (-e $dirVersion){
        # VERSION: Use version + CLEARCASE_XPN
        $commandLine ="cmd /c  copy  \"$dirVersion\" \"$Destination$FileName\" ";

        $result=system($commandLine);

				if ($result != 0){

            print "[ERROR] $commandLine = $result.\n";
            return 0;
          }   
			} else {
			
			   print "[WARNING] $dirVersion cannot be found in view.\n";
			} 
		}

      }

    print "Files copied\n\n";


    return 1;

  }

########################################################################
# Method:     getLatestVersionFiles
# Function:   finds files and copies latest version (not the labelled version ) to location 
# Inputs:     none
# Outputs:    none
# Return:     0/1 (0 if failed, 1 if successful)
# Notes:      Does not allow spaces in the file names
########################################################################
sub getLatestVersionFiles
  {
    # get array of VOBs
    my @VOBLIST = split(/,/, $g_voblist);

    my $vob     = "";


	foreach $vob (@VOBLIST){

        print "Copying files for '$vob' vob to $g_releasePath\\$vob ...\n";

        #Create a VOB release folder 
          mkdir($g_releasePath . "\\" . $vob , 0777) ; #or die "Can't create directory: $!"; 

        # Build command line
        $commandLine ="cleartool find $g_drive:\\$vob -element \"{lbtype_sub($g_label)}\" -exec \"cmd /c copy  \%CLEARCASE_PN\% $g_releasePath\\$vob\\ \" ";

        print "Running search: $commandLine\n\n";

        $result=system($commandLine);

		if ($result != 0){

            print "result of $commandLine = $result.\n";
            return 0;
          }   
        print "Files copied from '$vob' vob.\n\n";

      }

    return 1;

  }


########################################################################
# Method:     writeUsage
# Function:   Prints the command line usage help to screen
# Inputs:     none
# Outputs:    none
# Return:     none
# Notes:      
########################################################################
sub writeUsage
  {

  print <<DISPLAYUSAGE;

  ======================================
  =GetLabel.pl command-line arguments. =
  ======================================


  Usage:
  ======
  GetLabel.pl -label=<label_name> -drive=<mounted drive> 
                -voblist=<csv list of vobs> [-user=<user name>]
                [-copyto=<path to copy to>] [-cf] [-help]


  label   = Mandatory. The label to search for in Clearcase
  drive   = Mandatory. The letter of the mounted drive containing the VOBs
  voblist = Mandatory. Comma separated list of VOB names mounted to the drive.
  user    = optional. Clearcase User name to extract files for.
  copyto  = Optional. The path to copy the files retrieved from clearcase to.
  cf      = Optional. Create the subfolder structure under the release folder.
  help    = Optional. Display this hep


  examples:
  =========

  Retrieve a label 'WB_CR68' from vobs mounted on L drive for user 'frank'+ create folder:
  --------------------------------------------------------------------------------------
  getlabel.pl -label=WB_CR68 -drive=L -voblist=topclass -user=frank -copyto=C:\\release -cf
  
  Retrieve a label 'WB_CR68' from two vobs mounted on L drive + create folder structure:
  --------------------------------------------------------------------------------------
  getlabel.pl -label=WB_CR68 -drive=L -voblist=esd,topclass -copyto=C:\\release -cf


  Retrieve a label 'WB_CR68' from two vobs mounted on L drive:
  ------------------------------------------------------------
  getlabel.pl -label=WB_CR68 -drive=L -voblist=esd,topclass -copyto=C:\\release


  Retrieve a label 'WB_CR68' from a particular vob mounted on L drive:
  --------------------------------------------------------------------
  getlabel.pl -label=WB_CR68 -drive=L -voblist=esd -copyto=C:\\release


  Retrieve list of files for label 'WB_CR68' from a particular vob
  ----------------------------------------------------------------
  getlabel.pl -label=WB_CR68 -drive=L -voblist=esd


  To display help:
  ---------------
  getlabel.pl -label=WB_CR68 -drive=L -voblist=esd -copyto=C:\\release -help
  OR
  getlabel.pl -help


DISPLAYUSAGE

  }

########################################################################
# Method:     MkDir
# Function:   Creates directory structure
# Inputs:     Full path for folder to create
# Outputs:    none
# Return:     0 if failed
# Notes:      
########################################################################
sub MkDir($)
  {
    my ($dir) = @_;
    if ( -d $dir )
      {
        print "MkDir $dir exists\n";
      }
    else
      {
        my $sofar = "";
        foreach ( split( /\\/, $dir ) )
          {
            #print "[$_]\n";
            if ( $sofar eq "" )
              {
                if ( $_ ne "" and $dir =~ /^\\\\/ )
                  {
                    $sofar = "\\\\$_";
                  }
                else
                  {
                    $sofar = $_;
                  }
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
                    return 0;
                  }
              }
          }
        print "MkDir $dir\n";
      }
  }