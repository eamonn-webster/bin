#
# Chaeck that all bean-message are defined...
#

use strict;

my $drive;

chdir("$drive/topclass/java/cnr/WebContent");

my $cmd = "grep -R bean:message .";

my @msgs;

if ( open( RESOURCES, "$drive/topclass/java/cnr/src/com/wbtsystems/cnr/resources.properties" ) ) {
    while ( <RESOURCES> ) {
        #print;
        if ( /([^=]+)=/ ) {
           #print "$1\n";
           my $msg = $1;
           if ( !grep( /^$msg$/, @msgs ) ) {
               @msgs = ( @msgs, $msg );
           }
        }
    }
    close(RESOURCES);
    if ( open( GREP, "$cmd |" ) ) {
        while ( <GREP> ) {
            my $line = $_;
            #print;
            if ( /<bean:message key="([^\"]+)"/ ) {
               #print "$1\n";
               my $msg = $1;
               if ( !grep( /^$msg$/, @msgs ) ) {
                   print "ERROR: $line $msg\n";
               }
            }
        }
        close( GREP );
    }
}
