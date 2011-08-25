#
# File: lspriv.pl
# Author: eweb
#
# Date:          Author:  Comments:
#

#
# List privates excluding temporary files...
#
# Usage lspriv.pl [driveletter]
#

use strict;
use File::Basename;

my $cctool = "cleartool";

my $driveletter;
my $drive = $ARGV[0];

if ( $drive =~ /(.):/ ) {
    $driveletter = $1;
}
elsif ( $drive =~ /^.$/ ) {
    $driveletter = $drive;
    $drive = $driveletter . ":";
}

my @pubidlheaders = (
  "TCPowerPointDocComMod.h",
  "tctypedefs.h",
  "tclangreader.h",
  "TCBase64Mod.h",
  "tcSCORM12Import.h",
  "tchtmlgenerate.h",
  "MetaDLLMod.h",
  "htmlclean.h",
  "tcqpimgr.h",
  "TCServerDacMod.h",
  "TCWordDocComMod.h",
  "DACCommonInterfaces.h",
  "tccomverter.h",
  "TCPlugDacMod.h",
  "common_interface.h",
  "tcAICCdoccom.h",
  "common_interface.h",
  "tcSCORMExport.h",
  "Scorm2Plug.h",
  "common_interface.h",
  "tcSCORMdoccom.h",
  "TcAICCExport.h",
  "common_interface.h",
  );

#my $privates = "c:\\temp\\$driveletter-privs.bat";
if ( open( PRIVS, "$cctool lspriv 2>&1 |" ) ) {
    #if ( open( PRIVSOUT, ">$privates" ) ) {
        while ( <PRIVS> ) {
            chomp;
            my ($file, $path) = fileparse($_);
            if ( /\[checkedout\]/ ) {
            }
            elsif ( /\\topclass\\oracle\\topclass\\Lisp\\gen/ ) {
            }
            elsif ( /\\topclass\\oracle\\topclass\\Lisp\\current/ ) {
            }
            elsif ( /\\topclass\\java\\cnr\\build\\classes/ ) {
            }
            elsif ( /\\topclass\\oracle\\topclass\\doc\\[0-9]+/ ) {
            }
            elsif ( /\\topclass\\oracle\\plugins\\sources\\cpi\\ws\\parser\\build/ ||
                    /\\topclass\\oracle\\plugins\\sources\\cpi\\ws\\java\\build/ ||
                    /\\topclass\\oracle\\plugins\\sources\\cpi\\ws\\gsoap/ ||
                    /build\.status/ ||
                    /db_account_success/ ||
                    /db_schema_success/ ) {
            }
            elsif ( /kDefault.*\.inc/ ) {
            }
            elsif ( /\.vcproj\.WEST\.eweb\.user/ ) {
            }
            elsif ( /\.obj$/ || /\.sbr$/ || /\.res$/ || /\.tlh$/ || /\.tli$/ || /\.idb$/ || /\.pdb$/ || /\.map$/ || /\.pch$/ || /\.bsc$/
                    || /\.exp$/ || /\.lib$/ || /\.opt$/ || /\.ncb$/ || /\.ilk$/ || /\.log$/ || /\.plg$/ ) {
            }
            elsif ( /\.dll$/ || /\.exe$/ ) {
            }
            elsif ( /\.lang$/ || /\.labels$/ ) {
            }
            elsif ( /\.class$/ || /\.prefs$/ ) {
            }
            elsif ( /SCORM1\.[0-9]\.jar$/i ) {
            }
            elsif ( /\.bak$/ || /\.old$/ || /\.contrib$/ || /\.contrib\.[0-9]+$/ || /\.keep$/ || /\.ann$/ || /\.temp$/ ) {
            }
            elsif ( /BuildLog\.htm/ || /\.embed\.manifest/ || /\.intermediate\.manifest/ || /FileListAbsolute\.txt/ ) {
            }
            elsif ( /mt\.dep/ ) {
            }
            elsif ( /dlldata\.c/ || /_i\.c$/ || /_p\.c$/ || /regsvr32\.trg/ || /\.tlb$/ || // ) {
            }
            elsif ( grep( /^$file$/, @pubidlheaders ) ) {
            }
            elsif ( -d ) {
                #print "$_\n";
            }
            else {
                print "$_\n";
                #print PRIVSOUT;
            }
        }
    #    close( PRIVSOUT );
    #}
    close( PRIVS );
}
