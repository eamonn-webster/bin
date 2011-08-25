
my $ViewDrive  = $ARGV[0];
my $CurDir     = ".";
my $CCTOOL     = "cleartool";

ProcessEachDsp( $CurDir, $ViewDrive );

sub ProcessEachDsp()
{
  my ($CurDir, $ViewDrive) = @_;

  if ( opendir( DIR, "$CurDir" ) )
    {
      my $file;
      my $Cmd;
      my $CmdOut;
      while ( defined( $file = readdir(DIR) ) )
        {
          if ( $file =~ /\.dsp$/ ) #&& $file =~ /conv/ )
            {
              #print "[$file]\n";

              if ( !open( DSPFILE, "$file") )
                {
                  print "**** Unable to open the project file - $file";
                }
              else
                {
                  print "Project $file\n";
                  while ( <DSPFILE> )
                    {
                      if ( /SOURCE="\$\(InputPath\)"/ )
                        {
                        }
                      elsif ( /SOURCE=.\\sources\\kDefault.+Template\.inc/ )
                        {
                        }
                      elsif ( /SOURCE=(.+)/ )
                        {
                          $src = $1;
                          #print "source=$src\n";
                          if ( $src =~ /"(.+)"/ )
                            {
                              $src = $1;
                            }
                          #print "Includes $src\n";
                          $fileExists = 0;
                          $ccFileExists = 0;
                          if ( -e $src )
                            {
                              $fileExists = 1;
                              $desc = `$CCTOOL desc -fmt "%m" "$src"`;
                              if ( $desc eq "version" )
                                {
                                  $ccFileExists = 1;
                                }
                              elsif ( $desc eq "view private object" )
                                {
                                  $ccFileExists = 1;
                                }
                              elsif ( $desc eq "**null meta type**" )
                                {
                                  print "Non-MVFS: $src\n";
                                  $ccFileExists = 0;
                                  @parts = split( /\\/, $src );
                                  $path = "";
                                  foreach ( @parts )
                                    {
                                      $next = $_;
                                      #print "[$next]";
                                      if ( $path eq "" )
                                        {
                                          $path = $next;
                                        }
                                      else
                                        {
                                          $path = $path . "\\" . $next;
                                        }
                                      #print "checking [$path]\n";
                                      $desc = `$CCTOOL desc -fmt "%m" "$path"`;
                                      if ( $desc eq "**null meta type**" )
                                        {
                                          print "Wrong case for [$next] in $src\n";
                                          last;
                                        }
                                    }
                                }
                              else #elsif ( $desc eq "" )
                                {
                                  #print "case wrong $src\n";
                                  $ccFileExists = 0;
                                }
                            }
                          else
                            {
                              print "file not found [$src]\n";
                            }
                        }
                    }
                  close(DSPFILE);
                }
            }
         }
      closedir(DIR);
    }
}
