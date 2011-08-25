#
# mkeclipseprj.pl
# Make an eclipse Project...
#

use strict;

# first we need to create the project using eclipse...

my $cmd = "copy $ccdrive\\topclass\\java\\$projname\\.* c:\\java\\workspace\\$projname";

print "$cmd\n";

system( $cmd );


my $cmd = "xcopy /s $ccdrive\\topclass\\java\\$projname\\.settings c:\\java\\workspace\\$projname\\.settings";

print "$cmd\n";

system( $cmd );

