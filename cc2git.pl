
#
# Transfer from clearcase into git
#

use strict;

# start at first label.
# set clearcase config spec.
# get events since previous label
# do we need to know the branch?
#  - new versions
#  - added elements
#  - removed elements
#  - links
#  - renames...

my $view = "git_view";
my $drive = "z:";

my $previous_label = "TC_500_BUILD_130";
my $current_label = "TC_500_BUILD_132";

open( CS, ">config-spec" ) or die;

print CS "element * $label\n";

close( CS );

run( "cleartool setcs -tag $view config-spec" );

my $cmd;
if ( $previous_label ) {
  $cmd = "cleartool find @vobs2use -all -version \"!lbtype_sub($previous_label) && lbtype_sub($current_label)\" -print";
}
else {
  $cmd = "cleartool find @vobs2use -all -version \"lbtype_sub($current_label)\" -print";
}

open( CHANGES, "$cmd |" ) or die;

while ( <CHANGES> ) {

}

foreach (@rmelems) {
  run( "git rm \"$_\"" );
}

foreach (@mkelems) {
  run( "git add \"$_\"" );
}

# git handle the renames
foreach (@renames) {
  my ($old, $new) = split(/,/);
  run( "git mv \"$old\" \"$new\"" );
}

# git add -u
  run( "git add -u" );

# status should be clean

#
# after each build a tar ball of the cleaned view...
#


#mkview -snapshot -tag clean_view
#    [ -tmo·de { insert_cr | transparent | strip_cr } ]
#    [ -stg·loc view-stgloc-name | -col·ocated_server
#    [ -hos·t hostname -hpa·th host-snapshot-view-pname
#    -gpa·th global-snapshot-view-pname ] | -vws view-storage-pname
#    [ -hos·t hostname -hpa·th host-storage-pname
#    -gpa·th global-storage-pname ] snapshot-view-pname

my $snapshot = lc $ENV{USERNAME} . "_snap";

$cmd = "cleartool mkview -snapshot -tag $snapshot -tmode insert_cr " . $ENV{TEMP} . "\\" . $snapshot;
