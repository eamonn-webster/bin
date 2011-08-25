use strict;

use Win32API::Net;

my $server = $ENV{LOGONSERVER};
my $user = "clearcase_albd";

   $server = "TEAK";

#my %info;

#Win32API::Net::UserGetInfo($server, $user, 10, \%info);

#print "Info: %info\n";

my @groups;

Win32API::Net::UserGetGroups($server, $user, \@groups);

print "User: $user Groups: @groups\n";