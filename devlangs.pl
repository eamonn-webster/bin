if ( open (BUILDLOG, ">lang.log") )
  {
    GenLangFiles( $ARGS[0], $ARGS[1], "Y" );
    close(BUILDLOG);
  }

sub GenLangFiles()
{
  my ($CurDir, $ViewDriveName, $UnicodeBuild) = @_;

  my $LangDir = "$ViewDriveName/topclass/oracle/topclass/languages";

  chdir( $LangDir );

  #StartDiv( "GenLangFiles", "Generating .lang and .labels" );

  my $LangUtils = "langutils";
  if ( $UnicodeBuild eq "Y" )
    {
      $LangUtils = $LangUtils . " -u";
    }
  $LangUtils =~ s!/!\\!g;              # do slashes

  if ( opendir( DIR, "." ) )
    {
      my $file;
      my $Cmd;
      my $CmdOut;
      while ( defined( $file = readdir(DIR) ) )
        {
          print "$file\n";
          if ( $file =~ /langrps\.dat$/ ) {
            #print "$file\n";
          }
          elsif ( $file =~ /_..\.dat$/ ) {
            #print "$file\n";
            # Generate .lang file
            $Cmd = "$LangUtils $file";
            print BUILDLOG "Command: $Cmd\n";
            $CmdOut = `$Cmd 2>&1`;
            print BUILDLOG "$CmdOut\n";
          }
          elsif ( $file =~ /_abc\.dat$/ ) {
            #print "$file\n";
            # Generate .lang file
            $Cmd = "$LangUtils $file";
            print BUILDLOG "Command: $Cmd\n";
            $CmdOut = `$Cmd 2>&1`;
            print BUILDLOG "$CmdOut\n";
          }
          elsif ( $file =~ /\.dat$/ ) {
            #print "$file\n";
            # Generate .lang file
            $Cmd = "$LangUtils $file";
            print BUILDLOG "Command: $Cmd\n";
            $CmdOut = `$Cmd 2>&1`;
            print BUILDLOG "$CmdOut\n";

            # Generate .labels file
            $Cmd = "$LangUtils -b $file";
            print BUILDLOG "Command: $Cmd\n";
            $CmdOut = `$Cmd 2>&1`;
            print BUILDLOG "$CmdOut\n";
          }
        }
      closedir(DIR);
    }
  else
    {
      print BUILDLOG "can't open directory $LangDir\n";
    }

  #EndDiv( "GenLangFiles", 1 );
  chdir( "$CurDir" );
}

