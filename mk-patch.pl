use strict;

my $drive;
my $patchdir = "c:/xyz";
#my $drive = "z:";

my $cmd = "cleartool find $drive/topclass $drive/authoring $drive/utils $drive/3rdparty -all -cview -version \"!lbtype_sub(TC_800_BUILD_026)\" -print";

if ( open( FILES, "$cmd |" ) ) {
    while ( <FILES> ) {
        chomp;
        s!\\!/!g;
        s!\@\@.+!!g;

        if ( -d ) {
            # print "DIR: $_\n";
        }
        #elsif ( m!/topclass/java/cnr/! ) {
        #    print "WAR: $_\n";
        #}
        elsif ( m!/topclass/lost\+found/! ) {
            #print "LOST: $_\n";
        }
        else {
            print "NEED: $_\n";
            if ( m!^/topclass/oracle/install/distribution/(.+)! ) {
               print "xcopy $_ $patchdir/$1\n";
            }
            elsif ( m!/topclass/java/cnr/(.+)! ) {
               print "xcopy $_ $patchdir/java/$1\n";
            }
        }
    }
}
