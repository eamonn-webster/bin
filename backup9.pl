use strict;

my $appdir = "c:\\java\\workspace\\tc900";
my $backupdir = "c:\\backups\\";

chdir( $appdir );

my ($sec, $min, $hour, $day, $mon, $year ) = localtime(time);

$year  = $year + 1900;

my @Months = ( "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" );

my $mon = @Months[$mon];

my $zipname = sprintf("%02d%s%04d", $day, $mon, $year );

my $cmd = "zip -r $zipname.zip . -i * -x build\\* -x *.bak";

print "$cmd\n";
system($cmd);

print "Zipped to $appdir\\$zipname.zip\n";

$cmd = "copy $appdir\\$zipname.zip $backupdir";

print "$cmd\n";
system($cmd);
