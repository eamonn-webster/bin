use strict;

#use Getopt::Std;
use Win32::TieRegistry;
use File::Basename;

$Registry->Delimiter("/");

#my $Classes = $Registry->{"HKEY_CLASSES_ROOT/CLSID/"};
my $Classes = $Registry->{"HKEY_LOCAL_MACHINE/Software/Classes/CLSID/"};

foreach my $clsid ( $Classes->SubKeyNames )
  {
    #print "$clsid\n";
    my $dll = $Classes->{"$clsid/InprocServer32//"};
    if ( $dll )
      {
        my $full = $dll;
        if ( $full =~ /%SystemRoot%/i )
          {
            $full =~ s/%SystemRoot%/$ENV{SystemRoot}/i ;
          }
        elsif ( $full =~ /%ProgramFiles%/i )
          {
            $full =~ s/%ProgramFiles%/$ENV{ProgramFiles}/i ;
          }
        elsif ( $full !~ /\\/i )
          {
            $full = $ENV{SystemRoot} . "\\system32\\$dll";
          }
        if ( -e $full )
          {
          }
        else
          {
            my ($name, $path) = fileparse($full);
            if ( $path ne ".\\" )
              {
                if ( -d $path )
                  {
                    print "Directory exists but file doesn't: $clsid $full\n";
                  }
                else
                  {
                    if ( $path =~ /C:\\Program Files\\Java/i )
                      {
                        $dll =~ s/C:\\Program Files\\Java/C:\\Java/i;
                        print "Changing $clsid $full to $dll\n";
                        $Classes->{"$clsid/InprocServer32//"} = $dll;
                      }
                    else
                      {
                        print "Directory doesn't exists: $clsid $full\n";
                        #print "$clsid $name $path\n";
                      }
                  }
              }
            else
              {
                #print "$clsid $dll\n";
              }
          }
        #if ( $dll eq "InprocServer32" )
        #  {
        #  }
        #else
        #  {
        #    for my $v ( keys( %{ $dll } ) )
        #      {
        #        if ( $v =~ /c:\\/i )
        #          {
        #            print "  $v\n";
        #          }
        #      }
        #  }
      }
  }

#search registry HKEY_CLASSES_ROOT\CSLID\{CAFEEFAC-0015-0000-0002-ABCDEFFEDCBB}
#InprocServer32\(Default)