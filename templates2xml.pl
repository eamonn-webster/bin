#
# File: templates2xml.pl
# Author: eweb
# Contents: Write an xml preferences file containing all (customised) templates.
#
# Date:          Author:  Comments:
# 13th Mar 2007  eweb     Created.
# 29th Jul 2009  jroche   #00008 Added a mode and label parameter to allow run for a Label or a Branch
# 29th Jul 2009  eweb     #00008 Handle ]]>
# 24th Dec 2009  fkav     #00008 Fix label versioning + Allow local file creation
#

use strict;
use File::Basename;

sub GetTemplates( $$$$$ )
  {
    my ( $mode, $start, $branch, $label, $xmlfile ) = @_;


    if ( $xmlfile eq "" )
      {
        $xmlfile = "templates.xml";
      }

    if ( $start eq "" )
      {
        $start = "\\topclass\\oracle\\topclass\\sources\\templates";
      }

    my $cmd = "cleartool find $start ";

    if ( $mode eq "1" )
      {

        if ( $label ne "" )
          {
            $cmd = "$cmd -ver lbtype($label) -print";
          }

      }
    elsif ( $mode eq "2" )
      {

        # Just do a local get - files have already been extracted so the dir command should be used
        # with the Bare flag /B 
          {
            $cmd = "dir \"$start\" /B";
          }

      }
    else
      {
        if ( $branch ne "" )
          {
            $cmd = "$cmd -element brtype($branch) -print";
          }

      }

    print "$cmd\n";
    my $find;
    my $versioned;

    if ( open( $find, "$cmd |") )
      {

    

        if ( open( TMPLS, ">$xmlfile" ) )
          {
            my @others;
            print TMPLS "<?xml version='1.0' encoding='utf-8' ?>\n";
            print TMPLS "<TopClass>\n";
            print TMPLS "  <section name=\"Templates\">\n";

            while ( <$find> )
              {
                chomp;
                my $full;
                if ( /(.*)\@\@$/ )
                  {
                    $full = $1;
                    $versioned = $full;
                  }
                elsif ( /(.*)\@\@(.*)/ )
                  {
                    $versioned = $1.'@@'.$2;
                    $full = $1;

                  }
                elsif ( $mode eq "2")
                  {
                    #DIR command will only write the bare filename. Must append the start
                    $full = $start. "\\" .$_;
                    $versioned = $full;
                  }
                  
                if ($full)
                  {
                    print "$full [$versioned]\n";
                    my ($name, $path, $ext) = fileparse( $full, qr/\.[^.]*/ );
                    if ( $name eq "ExerciseCompletionRecord" )
                      {
                         @others = ( @others, $versioned );
                      }
                    else
                      {
                        print "$path $name $ext\n";
                        if ( open( TMPL, $versioned ) )
                          {
                            print TMPLS "    <option name=\"$name\">\n";
                            print TMPLS "      <Template><![CDATA[";
                            while ( <TMPL> )
                              {
                                if ( /\]\]>/ )
                                  {
                                    #print "<" . $_;
                                    s!\]\]>!\]\]\]\]><\!\[CDATA\[>!g;
                                    #print ">" . $_;
                                  }
                                print TMPLS;
                              }
                            print TMPLS "]]></Template>\n";
                            print TMPLS "    </option>\n";
                            close( TMPL );
                          }
                       }
                    #$filepath = \esd\templates\Home.tmpl
                  }
              }

            print TMPLS "  </section>\n";
            for my $full ( @others )
              {
                #print "john";
                # Allow for versioned files when label used
				if ( /(.*)\@\@(.*)/ )
				  {
					$versioned = $1.'@@'.$2;
					$full = $1;
				
                  }
                else
                  {
                    $versioned = $full;
                  }
                  
                my ($name, $path, $ext) = fileparse( $full, qr/\.[^.]*/ );
                my $section;
                my $option;
                if ( $name eq "ExerciseCompletionRecord" )
                  {
                    $section = "Plugin_Completion";
                    $option = "CompletionRecord";
                  }
                print "$full [$versioned]\n";
                if ( $section ne "" and $option ne "" )
                  {
                    print "$path $name $ext\n";
                    if ( open( TMPL, $versioned ) )
                      {
                        print TMPLS "  <section name=\"$section\">\n";
                        print TMPLS "    <option name=\"$option\">\n";
                        print TMPLS "      <![CDATA[";
                        while ( <TMPL> )
                          {
                            if ( /\]\]>/ )
                              {
                                #print "<" . $_;
                                s!\]\]>!\]\]\]\]><\!\[CDATA\[>!g;
                                #print ">" . $_;
                              }
                            print TMPLS;
                          }
                        print TMPLS "]]>\n";
                        print TMPLS "    </option>\n";
                        print TMPLS "  </section>\n";
                        close( TMPL );
                      }
                   }
              }
            print TMPLS "</TopClass>\n";
            close( TMPLS );
          }
      }
  }

if ( $#ARGV == -1 )
  {
    print "Usage: perl $0 mode start branch label xmlfile\n\n";
    print "MODE:  0, 1 or 2 \n";
    print "MODE:  0 = run for the whole branch specified\n";
    print "MODE:  1 = run for a label within the branch\n";
    print "MODE:  2 = run for local template files\n";
    print "e.g.perl $0 0 \\topclass\\oracle\\topclass\\sources\\templates nissan_8_working NISSAN_REL0001 NISSAN_REL0001.xml\n";
    print "e.g.perl $0 1 \\topclass\\oracle\\topclass\\sources\\templates '' NISSAN_REL0001 NISSAN_REL0001.xml\n";
    print "e.g.perl $0 2 \\topclass\\oracle\\topclass\\sources\\templates '' '' NISSAN_REL0001.xml\n";

  }
else
  {
    GetTemplates( $ARGV[0], $ARGV[1], $ARGV[2], $ARGV[3], $ARGV[4] );
  }

