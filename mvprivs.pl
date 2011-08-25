use strict;


my $start   = "v:\\";
my $srcRoot = "cpp";
my $dstRoot = "temp";
my $listCmd = "escc lspriv |";

if ( 1 )
  {
    $start   = "c:\\temp\\tc750\\";
    $srcRoot = "TEMP";
    $dstRoot = "cpp";
    $listCmd = "dir /s /b";
    $listCmd = "c:\\temp\\xxx.txt";
  }
  
chdir( $start );

print "$listCmd\n";

if ( open( PRIVS, "$listCmd" ) )
  {
    while ( <PRIVS> )
      {
        print;
        chomp;
        my $priv = $_;
        if ( !-e $priv )
          {
          }
        elsif ( /buildno\.h$/ )
          {
          }
        elsif ( /C:\\$srcRoot\\tc750\\authoring/ || 
                /C:\\$srcRoot\\tc750\\topclass\\oracle\\plugins/ || 
                /C:\\$srcRoot\\tc750\\topclass\\oracle\\topclass/ 
              )
          {
            my @parts = split( /\\/, $priv );
            my $path = "";
            foreach ( @parts )
              {
                if ( $path ne "" )
                  {
                    $path = $path . "\\";
                  }
                $path = $path . $_;
                my $dest = $path;
                if ( lc $path eq "c:" )
                  {
                  }
                elsif ( -d $path )
                  {
                    $dest =~ s/C:\\$srcRoot/C:\\$dstRoot/;
                    if ( !-d $dest )
                      {
                        my $cmd = "mkdir $dest";
                        print "$cmd\n";
                        system( $cmd );
                      }
                  }
                elsif ( -e $path )
                  {
                    $dest =~ s/C:\\$srcRoot/C:\\$dstRoot/;
                    my $cmd = "move $path $dest";
                    print "$cmd\n";
                    system( $cmd );
                  }
              }
          }
      }
    close( PRIVS );
  }

