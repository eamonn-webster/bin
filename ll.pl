#lint processing

$lint = "c:\\lint\\lint-nt";
#$lint mobilelnt.lnt mobile.lnt > mobilelnt-1.out
#$lint topclasslnt.lnt topclass.lnt > topclasslnt-1.out

$some_dir = "U:\\topclass\\oracle\\topclass\\";

@dsps = {#{ "backdoor",     "backdoor - Win32 Release" },
         #{ "backdoord",    "backdoord - Win32 Release" },
          { "basic",        "basic - Win32 Release" },
          { "boolqpi",      "boolqpi - Win32 Release" },
          { "cgi",          "cgi - Win32 Release" },
          { "CgiClient",    "CgiClient - Win32 Release" },
          { "check",        "check - Win32 Release" },
          { "converter",    "converter - Win32 Release" },
          { "cookie",       "cookie - Win32 Release" },
         #{ "dbconsole",    "dbconsole - Win32 Release" },
          { "img",          "img - Win32 Release" },
         #{ "iPlanet40API", "iPlanet40API - Win32 Release" },
          { "isapistub",    "isapistub - Win32 Release" },
          { "langutils",    "langutils - Win32 Release" },
          { "ldap",         "ldap - Win32 Release" },
          { "listm",        "listm - Win32 Release" },
         #{ "mac2dos",      "mac2dos - Win32 Release" },
          { "mca",          "mca - Win32 Release" },
          { "mco",          "mco - Win32 Release" },
          { "mobile",       "mobile - Win32 Std Release" },
         #{ "newlang",      "newlang - Win32 Release" },
          { "ntufl",        "ntufl - Win32 Release" },
          { "oraclesso",    "oraclesso - Win32 Release" },
          { "pickone",      "pickone - Win32 Release" },
          { "pound",        "pound - Win32 Release" },
          { "ppandp",       "ppandp - Win32 Std Release" },
         #{ "purge",        "purge - Win32 Release" },
         #{ "Scripts",      "Scripts - Win32 Release" },
          { "siteminder",   "siteminder - Win32 Release" },
         #{ "sqltest",      "sqltest - Win32 Release" },
          { "tcauth",       "tcauth - Win32 Release" },
          { "tcoci",        "tcoci - Win32 Release" },
          { "tcodbc",       "tcodbc - Win32 Release" },
          { "text",         "text - Win32 Release" },
          { "topclass",     "topclass - Win32 Release" },
          { "upload",       "upload - Win32 Release" },
          { "userlicgen",   "userlicgen - Win32 Release" },
          { "variimage",    "variimage - Win32 Release" },
          { "varitext",     "varitext - Win32 Release" },
          { "",             "" }
        };


#
# doSwitches
#
# what to do:
#    /nologo               ignore
#    /W3                   ignore
#    /GX                   ignore
#    /O2                   ignore
#    /D "WIN32"            -D"WIN32"
#    /YX                   ignore
#    /FD                   ignore
#    /c                    ignore
#

sub doSwitches( $$$$ )
  {
    my ($OUTFILE, $basecpp, $cpp, $dirs) = @_;
    print $OUTFILE "/*\n";
    print $OUTFILE "  Switches: $basecpp\n";
    print $OUTFILE "  Switches: $cpp\n";
    $cpp =~ s/\/nologo *//g;
    $cpp =~ s/\/W. *//g;
    $cpp =~ s/\/G. *//g;
    $cpp =~ s/\/O. *//g;
    $cpp =~ s/\/Y. *//g;
    $cpp =~ s/\/F. *//g;
    $cpp =~ s/\/c *//g;
    $cpp =~ s/\/D /-D/g;
    print $OUTFILE "  Switches: $cpp\n";
    print $OUTFILE "*/\n";
    @baseflags = split / /, $basecpp;
    @flags = split / /, $cpp;

    foreach $flag ( @flags )
      {
        print $OUTFILE "$flag\n";
      }

    foreach $dir ( @$dirs )
      {
        print $OUTFILE "-i$dir\n";
      }
  }

sub OutputStuff( $$$$$$ )
  {
    my ($dspstem, $config, $basecpp, $cpp, $sources, $dirs) = @_;

    my $lntfile = $dspstem . "-lint.lnt";
    if ( !open( OUTFILE, ">$lntfile" ) ) {
      print "Can't open output file $lntfile\n";
    }
    else {
      print OUTFILE "/*************************************************************************\n";
      print OUTFILE "\n";
      print OUTFILE "  Project: $dspstem\n";
      print OUTFILE "  Configuration: $config\n";
     #print OUTFILE "  Switches: $basecpp\n";
     #print OUTFILE "  Switches: $cpp\n";
      print OUTFILE "  Dirs: @dirs\n";
      print OUTFILE "\n";
      print OUTFILE "*************************************************************************/\n";
      print OUTFILE "\n";
      doSwitches( OUTFILE, $basecpp, $cpp, $dirs );
      print OUTFILE "@$sources\n";
      close OUTFILE;
    }
  }

sub ProcessDspFile($)
  {
    my ($dspstem) = @_;
    #print "$dspstem\n";

    if ( !open( DSPFILE, $dspfile ) ) {
      print "Can't open input file $dspfile\n";
    }
    else {
#      $lntfile = $dspstem . "lnt2.lnt";
#      if ( !open( LNTFILE, ">" . $lntfile ) ) {
#        print "Can't open lint file $lntfile\n";
#      }
#      else {
        # start processing
        # 1) determine list of configurations...
        # choose the one to use
        # get the compiler flags for that configuration
        # get the sources for that configuration
        #@dsplines = <DSPFILE>;

        $step = 1; # looking for configurations
        # 1 looking for configurations
        # 2 building list of configurations
        # 3 have list of configurations, so choose one
        # 4 look for configuration section
        # 5 have configuration section
        # 6 finished configuration look for target
        # 7 didn't find configuration section
        $config = "";
        $basecpp = "";
        $cpp = "";
        my @sources;
        my @dirs;
        while ( <DSPFILE> ) {
          chomp;
          #print "$_\n";
          if ( $step eq 1 ) {
            if ( /\!MESSAGE Possible choices for configuration are:/ ) {
              $step = 2;
            }
          }
          elsif ( $step eq 2 ) {
            if ( $_ eq "" ) {
              $step = 3;
              if ( $config eq "" ) {
                print "**** $dspstem can't determine config\n";
              }
              else {
                #print "$config\n";
              }
              $step = 4;
            }
            elsif ( /!MESSAGE "([^"]*)/ ) {
              $thisconfig = $1;
              #print "$thisconfig\n";
              if ( $thisconfig eq $dspstem . " - Win32 Release" ) {
                $config = $thisconfig;
              }
              elsif ( $config eq "" && $thisconfig eq $dspstem . " - Win32 Std Release" ) {
                $config = $thisconfig;
              }
            }
          }
          elsif ( $step eq 4 ) {
            if ( /IF  \"\$\(CFG\)\" == \"$config\"/ ) {
              $step = 5;
            }
            elsif ( /\!ENDIF/ ) {
              $step = 6;
            }
          }
          elsif ( $step eq 5 ) {
            if ( /\!ELSEIF/ || /\!ENDIF/ ) {
              $step = 6;
            }
            elsif ( /\# ADD BASE CPP/ ) {
              # base cpp options
              $basecpp = $'; # post match
              #print "$basecpp\n";
            }
            elsif ( /\# ADD CPP/ ) {
              # cpp options
              $cpp = $'; # post match
              #print "$cpp\n";
            }
            else {
              #print "$_\n";
            }
          }
          elsif ( $step eq 6 ) {
            if ( /SOURCE=(.*)\\(.*)\.cpp/ ) {
              @sources = (@sources, $1 . "\\" . $2 . ".cpp\n");
              print "Source file: $2 in $1\n";
              print "Sources: @sources\n";
              @dirs = (@dirs, $1);
              print "Source dir: $1\n";
              print "Dirs: @dirs\n";
            }
            elsif ( /\# End Target/ ) {
              $step = 8;
            }
          }
          elsif ( $step eq 8 ) {
            OutputStuff( $dspstem, $config, $basecpp, $cpp, \@sources, \@dirs );
          }
        }
#        close LNTFILE;
#      }
      close DSPFILE;
    }
  }

#while (<*.dsp>) {
#print "@ARGV[0]\n";
while (<@ARGV[0]>) {
  $dspfile = $_;
  #print "$_\n";
  if ( /([a-zA-Z0-9]*)\.dsp/ ) {
    ProcessDspFile($1);
  }
}
