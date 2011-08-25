#******************************************************************************
#
#  File: genall.pl
#  Author: eweb
#  Copyright WBT Systems, 2005-2006
#  Contents: (re)generates all .dat files from the usenglish files.
#
#******************************************************************************
#
# Date:          Author:  Comments:
#  7th Nov 2006  eweb     Generate unicode files.
#

# generate the .dat files

#$Cmd = "del *_abc.dat";
#print "Command: [$Cmd]\n";
#system( $Cmd );

opendir( DIR, "." ) or die "can't open directory";
while ( defined( $file = readdir(DIR) ) )
  {
    if ( $file =~ /langrps\.dat/ )
      {
        #print "$file\n";
      }
    elsif ( $file =~ /_..\.dat/ )
      {
        #print "$file\n";
      }
    elsif ( $file =~ /_abc\.dat/ )
      {
        #print "$file\n";
      }
    elsif ( $file =~ /\.dat/ )
      {
        $cmd = "langutils -A $file";
        print "$cmd\n";
        system( $cmd );
      }
  }
closedir(DIR);

