#
#
#

use strict;

# for each branch for each file.
# if a developer branch last should merge back to main/parent
# looking for cases where last meregs from main/parent.


my $parent = "/main";
my $branch = "eweb_740_work_5";
#$branch = "lmcgetti_800";
my $cmd = "cleartool find -all -version \"version($parent/$branch/LATEST) && merge($parent,$parent/$branch/LATEST) && !merge($parent/$branch/LATEST,$parent)\" -exec \"clearvtree \\\"%clearcase_pn%\\\"\"";

print "$cmd\n";
system( $cmd );

