#!/bin/usr/perl
#
# Welcome to GitSync - a commit and push script for easy using git!
# Copyright (C) 2009: Daniel Blaschke and Rene Sedmik
# Copyright (C) 2010: Daniel Blaschke
# Web: http://www.sourceforge.net/projects/gitsync/
#
# This script is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published
# by the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
#
# Last change: 2010-04-13
#
#############################################
# (GLOBAL) OPTIONS:
#############################################
use strict;

my $GIT_SERVER="auto";
my $USE_EDITOR="no";
my $GIT_DIR=".git";
# change these values to the names of your custom scripts, if
# you have any to be called before and after synchronizing
# with GitSync!
my $CUSTOM_START_SCRIPT="";
my $CUSTOM_END_SCRIPT="";

my $GS_config="";
my $GITCOMM="";
my $GITADDLIST="";
my $GIT_REP=".";

#############################################
# CODE:
#############################################

print "------------------------------------------------------------\n";
print "GitSync - a GIT update script\n";
print "Version 1.2.0\n";
print "------------------------------------------------------------\n";

# check for git-installation
my $GIT_PATH= `which git`;
if ( $GIT_PATH eq "" ) {
 print "\n";
 print "ERROR: command git not found! Please install the version control system 'git'\n";
 print "from www.git-scm.com before using this script!\n";
 exit( 1 );
}

#### define functions to be used later in this script:
# function for reading config files
sub READCFG () {
 if ( "$GS_config" ne "" ) {
    print "GitSync config '$GS_config' found - reading\n";
    if ( open( CFG, $GS_config ) ) {
      while ( <CFG> ) {
        chomp;
        my ( $GS_key, $line ) = ( /([^ ]+)\s+(.*)/ );
        if ( $GS_key eq "GIT_SERVER" ) { $GIT_SERVER=$line; };
        if ( $GS_key eq "USE_EDITOR" ) { $USE_EDITOR=$line; };
        if ( $GS_key eq "GIT_DIR" ) { $GIT_DIR=$line; };
        if ( $GS_key eq "CUSTOM_START_SCRIPT" ) { $CUSTOM_START_SCRIPT=$line; };
        if ( $GS_key eq "CUSTOM_END_SCRIPT" ) { $CUSTOM_END_SCRIPT=$line; };
      }
      close( CFG );
    }
 }
}

# function for calling git pull/push:
sub GITP ($) {
 if ( run("git $1") ) {
  print "ok.\n";
 }
 else {
  print "ERROR: GIT-$1 returned an error.\n";
  exit 2
 }
}

# function for calling CUSTOM_START/END_SCRIPT:
sub SCRIPT ($) {
 my ($a1) = @_;
 if ( $a1 ne "" ) {
  if ( -x "./$a1") {
  print "Calling custom script '$a1' ...\n";
  run( "./$a1" );
  if ( "$a1" eq "$CUSTOM_START_SCRIPT" ) {
   print "done.\n";
   print "---------------------------------------\n";
  }
  else {
  print "WARNING: Unable to call your custom script '$a1'.";
  print "Make sure it is present and executable!\n";
  }
 }
}

sub run($) {
  my ($cmd) = @_;
  my $o;
  print "$cmd\n";
  if ( open( $o, "$cmd |" ) ) {
    while ( <$o> ) {
      print;
    }
    close( $o );
    return 1;
  }
  return 0;
}

# function for invoking git commit:
sub GITC (;$$) {
 my ($a1, $a2) = @_;
 if ( $GITADDLIST eq "" ) {
  if ( "$a1" eq "" ) {
   run( "git commit -a" );
  }
  else {
   run( "git commit -a $a1 \"$a2\"" );
  }
 }
 elsif ( "$a2" eq "" ) {
   run( "git commit" );
  }
  else {
   run( "git commit $a1 \"$a2\"" );
  }
 }
}
####


# parsing command line arguments

my $PARSE;
for ( @ARGV ) {
 if ( "$PARSE" eq "-m" ) { $GITCOMM=$_; }
 if ( "$PARSE" eq "-f" ) { $GITADDLIST=$_; }
 $PARSE=$_
}

if ( "$PARSE" ne "" and "$PARSE" ne "$GITCOMM" and "$PARSE" ne "$GITADDLIST" ) { $GIT_REP=$PARSE; }


# entering the directory of the repository
if ( chdir( $GIT_REP ) ) {
 #continue
}
else {
 print "\n";
 print "ERROR: folder '$GIT_REP' does not exist. Possibly a mistyped command line argument?\n";
 print "GitSync-syntax is (where all arguments are optional):\n";
 print "gitsync -m 'commit Message' -f 'Files to add' /location/of/repository\n";
 exit(1);
}


my $HOME = $ENV{HOME};

# searching for custom GitSync-configuration file
if ( -r "$HOME/gitsync.conf") { $GS_config="$HOME/gitsync.conf"; }
if ( -r "$HOME/.gitsync.conf") { $GS_config="$HOME/.gitsync.conf"; }
READCFG();
$GS_config="";
if ( -r "./gitsync.conf") { $GS_config="./gitsync.conf"; }
READCFG();


# check values of variables for validity
if ( $GIT_SERVER ne "yes" and $GIT_SERVER ne "no" and $GIT_SERVER ne "auto" ) {
 print "ERROR: invalid gitsync-configuration!\n";
 exit(1);
}

my $dirok;
# check if we are in the correct directory
if ( -r "./$GIT_DIR/config" ) {
   $dirok=1;
}
else {
   print "ERROR: Please call this script from the base directory of your git-repository!\n";
   exit(1);
}

my $EDITOR_PATH;
# if USE_EDITOR is set to the name of an editor, use it
if ( $ENV{USE_EDITOR} ne "yes" and $ENV{USE_EDITOR} ne "no" ) {
  $EDITOR_PATH="`which $ENV{USE_EDITOR}`";
  if ( "$EDITOR_PATH" eq "" ) {
    print "WARNING: editor '$ENV{USE_EDITOR}' does not exist, falling back to system default.\n";
  }
  else {
    #export EDITOR=$USE_EDITOR
    $ENV{EDITOR} =$USE_EDITOR;
  }
  $USE_EDITOR="yes"
}

# if present, calling custom "start" script first
SCRIPT( $CUSTOM_START_SCRIPT );

# if option GIT_SERVER="auto", check file .git/config to decide whether
# GIT_SERVER should be "yes" or "no":
if ( "$GIT_SERVER" eq "auto" ) {
  if ( `egrep 'remote' $GIT_DIR/config` ne "" ) {
    $GIT_SERVER="yes";
  }
  else {
    $GIT_SERVER="no";
  }
  print "Checking whether a git-server is configured: $GIT_SERVER\n";
}

# check if commit is necessary, else exit after pulling/merging from server
print "Checking repository status ...\n";
if ( `git status | grep 'nothing to commit'` ne "" ) {
  if ( "$GIT_SERVER" eq "yes" ) {
    print "Nothing to commit - updating your local repository instead ...\n";
    GITP( "pull" );
    print "Pushing to the global repository ...\n";
    GITP( "push" );
    # if present, calling custom "end" script before exiting
    SCRIPT( $CUSTOM_END_SCRIPT );
  }
  else {
    print "Nothing to commit (working directory clean).\n";
  }
  exit(0);
}

print "done.\n";
print "---------------------------------------\n";

# adding new files to the local repository
print "Adding new/changed files ...\n";
if ( "$GITADDLIST" eq "" ) {
  run( "git add ." );
}
else {
# print "Only adding: '$GITADDLIST'\n";
  run( "git add -v $GITADDLIST" );
}
if ( $! ) {
  print "ok.\n";
  print "---------------------------------------\n";
}
else {
  print "ERROR: GIT-add returned an error.\n";
  exit(2);
}

# committing the local changes
print "Committing all of your changes ...\n";

if ( "$GITCOMM" eq "" ) {
  if ( "$USE_EDITOR" eq "yes" ) {
    GITC();
  }
  else {
    print "Please type your comment: \n";
    my $gitcomment = readline();
    if ( $gitcomment ) {
      GITC( "-m", "$gitcomment" );
    }
    else {
      print "... using your comment: '$GITCOMM'\n";
      GITC( "-m", "$GITCOMM" );
    }
  }
  if ( $! ) {
    print "ok.\n";
    print "---------------------------------------\n";
  }
  else {
    print "ERROR: GIT-commit returned an error.\n";
    exit (2);
  }
}

if ( $GIT_SERVER eq "yes" ) {
  # initiating a pull to achieve a consistent local repository
  print "Updating your local repository ...\n";
  GITP( "pull" );
  # pushing the changes to the global repo
  print "Pushing to the global repository ...\n";
  GITP( "push" );
  print "---------------------------------------\n";
}

# if present, calling custom "end" script before exiting
SCRIPT( $CUSTOM_END_SCRIPT );

print "done.\n";
print "\n";

#exit(0);
# end of script
