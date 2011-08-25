use strict;


cleartool mktrtype -element -all -postop uncheckout -execunix "/usr/bin/perl /opt/rational/clearcase/triggers/uncheckout_post.pl" -execwin "ccperl \\cobalt\triggers\uncheckout_post.pl" -comment "Automatically remove empty branch" REMOVE_EMPTY_BRANCH_2

