###############################################################################################
#
# Script name   : updatedats.pl
# Created       : 23rd Dec 2003
# Author        : eweb
#
# Comments      :
#
#############################################################################################

# generate the .dat files

#$Cmd = "del *_abc.dat";
#print "Command: [$Cmd]\n";
#system( $Cmd );

opendir( DIR, "." ) or die "can't open directory";
while ( defined( $file = readdir(DIR) ) ) {
  if ( $file =~ /langrps\.dat/ ) {
    #print "$file\n";
  }
  elsif ( $file =~ /_..\.dat$/ ) {
    #print "$file\n";
  }
  elsif ( $file =~ /\.dat$/ ) {
    print "$file\n";
    $Cmd = "langutils -A $file";
    #print "Command: [$Cmd]\n";
    system( $Cmd );
  }
}
closedir(DIR);

