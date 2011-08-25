#
# File: addtmpl.pl
# Author: eweb
# Copyright WBT Systems, 1995-2011
# Contents:
#
# Date:          Author:  Comments:
#  4th Dec 2008  eweb     #00008 Add a template to the project
# 22nd Jan 2009  eweb     #00008 Handling vcproj
#  5th Feb 2009  eweb     #00008 Don't check back in, Spaces in strings
# 11th Feb 2009  eweb     #0008 Handle formdef fragments
#  4th Mar 2009  eweb     #00008 can specify file
#  8th Apr 2009  eweb     #00008 Incorrect code fragment
# 16th Apr 2009  eweb     #00008 Add to vcproj.vspscc
#  2nd Jul 2009  eweb     #00008 dsp (pre 8.0) no templates folder
#  2nd Nov 2009  eweb     #00008 die if bad name
# 23rd Jun 2010  eweb     #00008 ExtraInfo templates
# 28th Jun 2010  eweb     #00008 CExtraInfoTemplateOption
#  8th Aug 2010  eweb     #00008 Logging, * to check all
#  6th Jan 2011  eweb     #00008 Adding template at end

use strict;

# add a template to the project.

my %checkouts;

my $cctool1 = "cleartool"; # informational
my $cctool2 = "cleartool"; # eaisly undoable
my $cctool3 = "cleartool"; # harder to undo
my $cctool4 = "cleartool"; # impossible to undo

my $verbose = 1;
my $addtoproj = 1;
my $ccdrive;

sub entryForTemplateInc($) {
  my ($name) = @_;

  my $x = "SOURCE=.\\sources\\kDefault${name}Template.inc\n"
        . "# End Source File\n"
        . "# Begin Source File\n"
        . "\n";
  return $x;
}

sub entryForTemplate($$) {
  my ($name, $project) = @_;

  my $part = "\n"
           . "# Begin Custom Build\n"
           . "InputDir=.\\sources\n"
           . "InputPath=.\\sources\\$name.tmpl\n"
           . "InputName=$name\n"
           . "\n"
           . "\"\$(InputDir)\\kDefault\$(InputName)Template.inc\" : \$(SOURCE) \"\$(INTDIR)\" \"\$(OUTDIR)\"\n"
           . "\tperl \$(InputDir)\\tmpltostring.pl \$(InputDir)\\\$(InputName).tmpl \$(InputDir)\\kDefault\$(InputName)Template.inc\n"
           . "\n"
           . "# End Custom Build\n"
           . "\n";

  my $x;
  if ($project eq "topclass") {
     $x = "SOURCE=.\\sources\\$name.tmpl\n"
        . "\n"
        . "!IF  \"\$(CFG)\" == \"topclass - Win32 Debug\"\n"
        . $part
        . "!ELSEIF  \"\$(CFG)\" == \"topclass - Win32 Release\"\n"
        . $part
        . "!ELSEIF  \"\$(CFG)\" == \"topclass - Win32 Debug Dll\"\n"
        . $part
        . "!ELSEIF  \"\$(CFG)\" == \"topclass - Win32 Release Dll\"\n"
        . $part
        . "!ENDIF\n"
        . "\n"
        . "# End Source File\n"
        . "# Begin Source File\n"
        . "\n";
  }
  elsif ($project eq "mobile") {
     $x = "SOURCE=.\\sources\\$name.tmpl\n"
        . "\n"
        . "!IF  \"\$(CFG)\" == \"mobile - Win32 Std Debug\"\n"
        . $part
        . "!ELSEIF  \"\$(CFG)\" == \"mobile - Win32 Std Release\"\n"
        . $part
        . "!ENDIF\n"
        . "\n"
        . "# End Source File\n"
        . "# Begin Source File\n"
        . "\n";
  }
  else {
     $x = "SOURCE=.\\sources\\$name.tmpl\n"
        . "\n"
        . "!IF  \"\$(CFG)\" == \"$project - Win32 Debug\"\n"
        . $part
        . "!ELSEIF  \"\$(CFG)\" == \"$project - Win32 Release\"\n"
        . $part
        . "!ENDIF\n"
        . "\n"
        . "# End Source File\n"
        . "# Begin Source File\n"
        . "\n";
  }
  return $x;
}

#sub vcprojConfigEntryForTemplate($) {
#  my ($config) = @_;
#
#  my $p = "\t\t\t\t<FileConfiguration\n"
#        . "\t\t\t\t\tName=\"$config\"\n"
#        . "\t\t\t\t\t>\n"
#        . "\t\t\t\t\t<Tool\n"
#        . "\t\t\t\t\t\tName=\"VCCustomBuildTool\"\n"
#        . "\t\t\t\t\t\tCommandLine=\"perl \$(ProjectDir)tmpltostring.pl \$(InputDir)\$(InputName).tmpl \$(InputDir)..\\kDefault\$(InputName)Template.inc&#x0D;&#x0A;\"\n"
#        . "\t\t\t\t\t\tOutputs=\"\$(InputDir)..\\kDefault\$(InputName)Template.inc\"\n"
#        . "\t\t\t\t\t/>\n"
#        . "\t\t\t\t</FileConfiguration>\n";
#  return $p;
#}

sub vcprojEntryForTemplateInc($;$) {
  my ($name,$atend) = @_;
  my $x;
  if ( $atend ) {
    $x = "\t\t\t\t<File\n";
  }
     $x .= "\t\t\t\t\tRelativePath=\"sources\\kDefault${name}Template.inc\"\n"
        . "\t\t\t\t\t>\n"
        . "\t\t\t\t</File>\n";
  if ( !$atend ) {
    $x .= "\t\t\t\t<File\n";
  }
  return $x;
}

sub vcprojEntryForTemplate($$;$) {
  my ($name, $project, $atend) = @_;

  my $x;
  if ( $atend ) {
    $x = "\t\t\t<File\n";
  }
  $x .= "\t\t\t\tRelativePath=\"sources\\templates\\$name.tmpl\"\n"
      . "\t\t\t\t>\n"
      . "\t\t\t</File>\n";
  if ( !$atend ) {
    $x .= "\t\t\t<File\n";
  }

  return $x;
}


sub getCppCode($$) {
  my ($name, $type) = @_;

  my $str = $name;
  $str =~ s/([a-z])([A-Z])/\1 \2/g;
  my $x = "";
  if ( $type eq "expand" ) {
    $x = "DEFSTRING(str${name}Template, \"${str}\")\n"
       . "#include \"kDefault${name}Template.inc\"\n"
       . "\n"
       . "void BindFor${name}( CPercentBindings& UNUSED(bindings) )\n"
       . "  {\n"
       . "  }\n"
       . "\n"
       . "void Get${name}Bindings( CPercentBindings& bindings )\n"
       . "  {\n"
       . "    BindFor${name}( bindings );\n"
       . "  }\n"
       . "\n"
       . "CTemplateOption g${name}Template( 0, _TEXT(\"${name}\"), kDefault${name}Template, true, true, 0, Get${name}Bindings, str${name}Template );\n"
       . "\n";
  }
  elsif ( $type eq "style" ) {
    $x = "DEFSTRING(str${name}Template, \"${str}\")\n"
       . "#include \"kDefault${name}Template.inc\"\n"
       . "\n"
       . "CTemplateOption g${name}Template( 0, _TEXT(\"${name}\"), kDefault${name}Template, true, false, 0, GetGlobalPageBindings, str${name}Template );\n"
       . "\n";
  }
  elsif ( $type eq "command" ) {
    $x = "DEFSTRING(str${name}Template, \"${str}\")\n"
       . "const TCHAR* tok${name}( void ) { return _TEXT(\"${name}\"); }\n"
       . "#include \"kDefault${name}Template.inc\"\n"
       . "\n"
       . "void BindFor${name}( CPercentBindings& UNUSED(bindings) )\n"
       . "  {\n"
       . "  }\n"
       . "\n"
       . "void Get${name}Bindings( CPercentBindings& bindings )\n"
       . "  {\n"
       . "    BindFor${name}( bindings );\n"
       . "  }\n"
       . "\n"
       . "CTemplateOption g${name}Template( 0, _TEXT(\"${name}\"), kDefault${name}Template, true, true, 0, Get${name}Bindings, str${name}Template );\n"
       . "\n"
       . "OSErr ${name}( requestInfo& ri )\n"
       . "  {\n"
       . "    CPercentBindings bindings( &ri );\n"
       . "    BindFor${name}( bindings );\n"
       . "\n"
       . "    bindings.expandTemplate( ri.result, g${name}Template, false );\n"
       . "\n"
       . "    return noErr;\n"
       . "  }\n"
       . "\n"
       . "CRegisterCommand s${name}( ${name}, kNormalCmd, 0, tok${name}() );\n"
       . "\n";
  }
  elsif ( $type eq "message" ) {
    $x = "DEFSTRING(str${name}Template, \"${str}\")\n"
       . "#include \"kDefault${name}Template.inc\"\n"
       . "\n"
       . "void BindFor${name}( CPercentBindings& bindings )\n"
       . "  {\n"
       . "    bindings.add( _TEXT(\"recipients\"),      CStringValue::New( _TEXT(\"\") ) );\n"
       . "  }\n"
       . "\n"
       . "void Get${name}Bindings( CPercentBindings& bindings )\n"
       . "  {\n"
       . "    BindFor${name}( bindings );\n"
       . "  }\n"
       . "\n"
       . "CMailTemplateOption g${name}Template( 0, _TEXT(\"${name}\"), kDefault${name}Template, false, true, Get${name}Bindings, str${name}Template );\n"
       . "\n";
  }
  elsif ( $type eq "formdef" ) {
    $x = "DEFSTRING(str${name}Template, \"${str} (Fragment)\")\n"
       . "#include \"kDefault${name}Template.inc\"\n"
       . "\n"
       . "void BindFor${name}( CPercentBindings& UNUSED(bindings) )\n"
       . "  {\n"
       . "  }\n"
       . "\n"
       . "void Get${name}Bindings( CPercentBindings& bindings )\n"
       . "  {\n"
       . "    BindFor${name}( bindings );\n"
       . "  }\n"
       . "\n"
       . "CTemplateOption g${name}Template( 0, _TEXT(\"${name}\"), kDefault${name}Template, false, true, 0, Get${name}Bindings, str${name}Template );\n"
       . "\n";
  }
  elsif ( $type eq "extrainfo" ) {
    $x = "DEFSTRING(str${name}Template, \"${str}\")\n"
       . "#include \"kDefault${name}Template.inc\"\n"
       . "\n"
       . "CExtraInfoTemplateOption g${name}Template( _TEXT(\"${name}\"), kDefault${name}Template, str${name}Template );\n"
       . "\n";
  }
  else {
    print "ERROR: unknow template type $type\n";
  }
  return $x;
}

sub processDsp($$$$$) {

  my ($dsp, $project, $tmplDir, $exclude, $add) = @_;

  chdir($tmplDir);
  my @templates = glob("*.tmpl" );

  my @templatesInDsp;

  if ( open( DSP, $dsp ) ) {
    while ( <DSP> ) {
      chomp;
      if ( /^SOURCE=.*\\([^\\]+)\.tmpl$/ ) {
        print "found $1\n" if ( $verbose );
        @templatesInDsp = (@templatesInDsp, $1);
      }
    }
    close( DSP );
  }

  for my $tmpl ( @templates ) {
    $tmpl =~ s!\.tmpl!!;
    if ( $exclude ne "" and $tmpl =~ /$exclude/) {
    }
    elsif ( !grep( /^$tmpl$/, @templatesInDsp ) ) {
      print "Need to add $tmpl\n";
      if ( $add ) {
        addTmpl2Dsp($tmpl, $dsp, $project);
      }
    }
  }
}

sub processvcproj($$$$$) {

  my ($dsp, $project, $tmplDir, $exclude, $add) = @_;

  chdir($tmplDir);
  my @templates = glob("*.tmpl" );

  my @templatesInDsp;

  if ( open( DSP, $dsp ) ) {
    while ( <DSP> ) {
      chomp;
      if ( /^\s+RelativePath=".*\\([^\\]+)\.tmpl"$/ ) {
        print "found $1\n" if ( $verbose > 1 );
        @templatesInDsp = (@templatesInDsp, $1);
      }
    }
    close( DSP );
  }

  print "\@templates: @templates\n" if ( $verbose > 1 );
  print "\@templatesInDsp: @templatesInDsp\n" if ( $verbose > 1 );
  for my $tmpl ( @templates ) {
    $tmpl =~ s!\.tmpl!!;
    if ( $exclude ne "" and $tmpl =~ /$exclude/) {
    }
    elsif ( !grep( /^$tmpl$/, @templatesInDsp ) ) {
      print "Need to add $tmpl\n";
      if ( $add ) {
        addTmpl2vcproj($tmpl, $dsp, $project);
      }
    }
  }
}

sub addTmpl2Dsp($$$) {
  my ($tmpl, $dsp, $project) = @_;
  print "Adding $tmpl to $project\n";
  my $display = 2;
  my $writtenTmpl;
  my $writtenInc;
  my $changed = 0;
  if ( open( DSPNEW, ">$dsp.new" ) ) {
    if ( open( DSPOLD, $dsp ) ) {
      while ( <DSPOLD> ) {
        my $line = $_;
        if ( /^SOURCE=.*\\([^\\]+)\.tmpl$/ ) {
          if ( !$writtenTmpl ) {
            if ( $1 eq $tmpl ) {
              print "WARNING: ${tmpl}.tmpl already in project\n";
              $writtenTmpl = 1;
            }
            elsif ( $1 ge $tmpl ) {
              # write it out....
              print "$1 ge $tmpl so writing tmpl entry\n";
              print DSPNEW entryForTemplate($tmpl, $project);
              $changed = 1;
              $writtenTmpl = 1;
            }
          }
          if ( $display eq 0 ) {
            $display = 1;
          }
          elsif ( $display eq 1 ) {
            $display = 2;
          }
        }
        if ( /^SOURCE=.*\\kDefault([^\\]+)Template\.inc$/ ) {
          if ( !$writtenInc ) {
            if ( $1 eq $tmpl ) {
              print "WARNING: kDefault${tmpl}Template.inc already in project\n";
              $writtenInc = 1;
            }
            elsif ( $1 ge $tmpl ) {
              # write it out....
              print "$1 ge $tmpl so writing inc entry\n";
              print DSPNEW entryForTemplateInc($tmpl);
              $changed = 1;
              $writtenInc = 1;
            }
          }
        }
        if ( $display eq 1 ) {
          print $line;
        }
        print DSPNEW $line;
      }
      close( DSPOLD );
    }
    close( DSPNEW );
    my $dosdsp = $dsp;
    $dosdsp =~ s !/!\\!g;
    if ( $changed eq 0 ) {
      my $cmd = "del $dosdsp.new";
      print "$cmd\n";
      system( $cmd );
    }
    else {
      checkOut( $dsp, "#00008 Adding template $tmpl" );
      my $cmd = "del $dosdsp.old";
      print "$cmd\n";
      system( $cmd );
      $cmd = "move $dosdsp $dosdsp.old";
      print "$cmd\n";
      system( $cmd );
      $cmd = "move $dosdsp.new $dosdsp";
      print "$cmd\n";
      system( $cmd );
   }
  }
}

sub addTmpl2vcproj($$$) {
  my ($tmpl, $vcproj, $project) = @_;
  print "Adding $tmpl to $project\n";
  my $display = 2;
  my $writtenTmpl;
  my $writtenInc;
  my $changed = 0;
  my $foundTmpls = 0;
  my $foundIncs = 0;
  if ( open( VCPROJNEW, ">$vcproj.new" ) ) {
    if ( open( VCPROJOLD, $vcproj ) ) {
      while ( <VCPROJOLD> ) {
        my $line = $_;
        if ( /^\s+RelativePath=\".*\\([^\\]+)\.tmpl\"$/ ) {
          $foundTmpls = 1;
          if ( !$writtenTmpl ) {
            if ( $1 eq $tmpl ) {
              print "WARNING: ${tmpl}.tmpl already in project\n";
              $writtenTmpl = 1;
            }
            elsif ( $1 ge $tmpl ) {
              # write it out....
              print "$1 ge $tmpl so writing tmpl entry\n";
              print VCPROJNEW vcprojEntryForTemplate($tmpl, $project);
              $changed = 1;
              $writtenTmpl = 1;
            }
          }
          if ( $display eq 0 ) {
            $display = 1;
          }
          elsif ( $display eq 1 ) {
            $display = 2;
          }
        }
        if ( $foundTmpls && !$writtenTmpl && /<Filter/ ) {
          # write it out....
          print "Found <Filter..> so writing tmpl entry\n";
          print VCPROJNEW vcprojEntryForTemplate($tmpl, $project,1);
          $changed = 1;
          $writtenTmpl = 1;
        }
        if ( /^\s+RelativePath=\".*\\kDefault([^\\]+)Template\.inc\"$/ ) {
          $foundIncs = 1;
          if ( !$writtenInc ) {
            if ( $1 eq $tmpl ) {
              print "$1 eq $tmpl so not writing entry\n";
              print "WARNING: kDefault${tmpl}Template.inc already in project\n";
              $writtenInc = 1;
            }
            elsif ( $1 ge $tmpl ) {
              print "$1 ge $tmpl so writing inc entry\n";
              # write it out....
              print VCPROJNEW vcprojEntryForTemplateInc($tmpl);
              $changed = 1;
              $writtenInc = 1;
            }
          }
        }
        if ( $foundIncs && !$writtenInc && /<\/Filter/ ) {
          print "Found <\/Filter> so writing inc entry\n";
          # write it out....
          print VCPROJNEW vcprojEntryForTemplateInc($tmpl,1);
          $changed = 1;
          $writtenInc = 1;
        }
        if ( $display eq 1 ) {
          print $line;
        }
        print VCPROJNEW $line;
      }
      close( VCPROJOLD );
    }
    close( VCPROJNEW );
    my $dosvcproj = $vcproj;
    $dosvcproj =~ s !/!\\!g;
    if ( $changed eq 0 ) {
      my $cmd = "del $dosvcproj.new";
      print "$cmd\n";
      system( $cmd );
    }
    else {
      checkOut( $vcproj, "#00008 Adding template $tmpl" );
      my $cmd = "del $dosvcproj.old";
      print "$cmd\n";
      system( $cmd );
      $cmd = "move $dosvcproj $dosvcproj.old";
      print "$cmd\n";
      system( $cmd );
      $cmd = "move $dosvcproj.new $dosvcproj";
      print "$cmd\n";
      system( $cmd );
   }
  }
}

sub addTmpl2vcprojvspscc($$$) {
  my ($tmpl, $vcproj, $project) = @_;
  $vcproj = $vcproj . ".vspscc";
  print "Adding $tmpl to $project\n";
  my $display = 2;
  my $foundInc;
  my $changed = 0;
  if ( open( VCPROJNEW, ">$vcproj.new" ) ) {
    if ( open( VCPROJOLD, $vcproj ) ) {
      my $files = 0;
      while ( <VCPROJOLD> ) {
        my $line = $_;
        if ( /^\"NUMBER_OF_EXCLUDED_FILES\" = \"([0-9]+)\"$/ ) {
          print $line;
          $files = $1;
          my $newfiles = $files + 1;
          $line =~ s/$1/$newfiles/;
        }
        if ( /^\"EXCLUDED_FILE[0-9]+\" = \"sources\\\\kDefault(.+)Template.inc\"$/ ) {
          if ( $1 eq $tmpl ) {
            $foundInc = 1;
          }
        }
        if ( /^\"ORIGINAL_PROJECT_FILE_PATH\"/ ) {
          # end of list
          if ( !$foundInc ) {
            print VCPROJNEW "\"EXCLUDED_FILE$files\" = \"sources\\\\kDefault${tmpl}Template.inc\"\n";
            $changed = 1;
          }
        }

        if ( $display eq 1 ) {
          print $line;
        }
        print VCPROJNEW $line;
      }
      close( VCPROJOLD );
    }
    close( VCPROJNEW );
    my $dosvcproj = $vcproj;
    $dosvcproj =~ s !/!\\!g;
    if ( $changed eq 0 ) {
      my $cmd = "del $dosvcproj.new";
      print "$cmd\n";
      system( $cmd );
    }
    else {
      checkOut( $vcproj, "#00008 Adding template $tmpl" );
      my $cmd = "del $dosvcproj.old";
      print "$cmd\n";
      system( $cmd );
      $cmd = "move $dosvcproj $dosvcproj.old";
      print "$cmd\n";
      system( $cmd );
      $cmd = "move $dosvcproj.new $dosvcproj";
      print "$cmd\n";
      system( $cmd );
   }
  }
}

sub addTmpl2Cpp($$$) {
  my ($tmpl, $cpp, $type) = @_;
  print "Adding $tmpl\n";
  my $marker = quotemeta('/**** DO NOT MOVE - PUT NEW TEMPLATES HERE - DO NOT MOVE ****/');
  my $written;
  my $changed = 0;
  if ( open( CPPNEW, ">$cpp.new" ) ) {
    if ( open( CPPOLD, $cpp ) ) {
      while ( <CPPOLD> ) {
        my $line = $_;
        if ( /#include "kDefault(.+)Template.inc"/ and $1 eq $tmpl ) {
          print "WARNING: found kDefault${tmpl}Template.inc\n";
          $written = 1;
        }
        elsif ( !$written && /$marker/ ) {
          # write it out....
          $written = 1;
          print CPPNEW getCppCode($tmpl,$type);
          $changed = 1;
        }
        print CPPNEW $line;
      }
      close( CPPOLD );
      if ( !$written ) {
        # write it out....
        print "ERROR no marker so adding at end of file\n";
        $written = 1;
        print CPPNEW getCppCode($tmpl,$type);
        $changed = 1;
      }
    }
    close( CPPNEW );
    my $doscpp = $cpp;
    $doscpp =~ s !/!\\!g;
    if ( $changed eq 0 ) {
      my $cmd = "del $doscpp.new";
      print "$cmd\n";
      system( $cmd );
    }
    else {
      checkOut( $cpp, "#00008 Adding template $tmpl" );
      my $doscpp = $cpp;
      $doscpp =~ s !/!\\!g;
      my $cmd = "del $doscpp.old";
      print "$cmd\n";
      system( $cmd );
      $cmd = "move $doscpp $doscpp.old";
      print "$cmd\n";
      system( $cmd );
      $cmd = "move $doscpp.new $doscpp";
      print "$cmd\n";
      system( $cmd );
    }
  }
}

sub checkIn($$)
  {
    my ($file, $comment) = @_;

    my $cmd = "$cctool3 ci -c \"$comment\" $file";
    print "$cmd\n";
    my $results = `$cmd 2>&1`;

    if ( $results =~ /Error: By default, won\'t create version with data identical to predecessor./ )
      {
        # hasn't changed so undo the check out.
        print " - unchanged undoing checkout";
        $cmd = "$cctool3 unco -rm $file";
        $results = $results . "\n" . $cmd . "\n" . `$cmd 2>&1`;
      }
    elsif ( $results =~ /Error: Not an element:/ )
      {
        print " - Not an element";
        # Not an element
      }
    elsif ( $results =~ /Error:/ )
      {
        print " - Error";
        # Not an element
      }
    else
      {
        # Not an element
      }

    print "$results\n";
  }

sub checkOut($$)
  {
    my ($file, $comment) = @_;

    $checkouts{$file} = $comment;

    my $cmd = "$cctool2 co -c \"$comment\" $file";

    print "$cmd\n";

    my $results = `$cmd 2>&1`;

    if ( $results =~ /Error: Element "(.+)" is already checked out to view "(.+)"/ )
      {
        print "already checked out";
      }
    elsif ( $results =~ /Error: Not a vob object:/ )
      {
        # Not an element
        print " - Not a vob object";
      }
    elsif ( $results =~ /Error: / )
      {
        print " - Error";
      }
    print "$results\n";
  }


my $name = $ARGV[0];
my $type = $ARGV[1];
my $project = $ARGV[2];

my $cclevel = 2;

$cctool1 = "echo cleartool" if ( $cclevel < 1 ); # informational
$cctool2 = "echo cleartool" if ( $cclevel < 2 ); # eaisly undoable
$cctool3 = "echo cleartool" if ( $cclevel < 3 ); # harder to undo
$cctool4 = "echo cleartool" if ( $cclevel < 4 ); # impossible to undo


if ( $name eq "*" ) {
  $addtoproj = 0;
  #$cclevel = 1;
  #processDsp("$ccdrive/topclass/oracle/topclass/topclass.dsp","topclass","$ccdrive/topclass/oracle/topclass/sources/templates","Player",$addtoproj);
  #processDsp("$ccdrive/topclass/oracle/topclass/mobile.dsp","mobile","$ccdrive/topclass/oracle/topclass/sources/templates","Msg");
  processvcproj("$ccdrive/topclass/oracle/topclass/topclass.vcproj","topclass","$ccdrive/topclass/oracle/topclass/sources/templates","DM39*|UserInfo",$addtoproj);
}
else {
  if ( $name !~ /^[A-Z][a-zA-Z0-9]+$/ ) {
    die "bad name $name";
  }
  my $file;
  if ( $project eq "" ) {
    $project = "topclass";
  }
  if ( $type eq "" ) {
    $type = "expand";
  }
  if ( $type eq "command" or $type eq "expand" ) {
    $file = "$ccdrive/topclass/oracle/topclass/sources/templates.cpp";
  }
  elsif ( $type eq "catreg" ) {
    $file = "$ccdrive/topclass/oracle/topclass/sources/wcatreg.cpp";
    $type = "expand";
  }
  elsif ( $type eq "message" ) {
    $file = "$ccdrive/topclass/oracle/topclass/sources/wcatreg.cpp";
  }
  elsif ( $type eq "style" ) {
    $file = "$ccdrive/topclass/oracle/topclass/sources/tc5style.cpp";
  }
  elsif ( $type eq "formdef" ) {
    $file = "$ccdrive/topclass/oracle/topclass/sources/editobj.cpp";
  }
  elsif ( $type eq "extrainfo" ) {
    $file = "$ccdrive/topclass/oracle/topclass/sources/wuprefs.cpp";
  }
  else {
    if ( -e "$ccdrive/topclass/oracle/topclass/sources/$type.cpp" ) {
      $file = "$ccdrive/topclass/oracle/topclass/sources/$type.cpp";
      $type = "expand";
    }
  }

  addTmpl2Cpp( $name, $file, $type );
  if ( $project ne "." ) {
    if ( $project eq "both" ) {
      addToProject("topclass", $name);
      addToProject("mobile", $name);
    }
    else {
      addToProject($project, $name);
    }
  }
}

sub addToProject($$) {
  my ($project, $name) = @_;
  my $dsp = "$ccdrive/topclass/oracle/topclass/$project.dsp";
  my $vcproj = "$ccdrive/topclass/oracle/topclass/$project.vcproj";
  addTmpl2Dsp( $name, $dsp, $project );
  addTmpl2vcproj( $name, $vcproj, $project );
  addTmpl2vcprojvspscc( $name, $vcproj, $project );
}
