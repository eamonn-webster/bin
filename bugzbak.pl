use strict;

my ($sec, $min, $hour, $day, $mon, $year) = localtime(time);

my $date = sprintf( "%04d-%02d-%02d", ($year + 1900), ($mon + 1), $day );


my $backups = "c:/backups/";

my $cmd = "mysqldump bugs -u bugs --password=bugs > ${backups}bugs-${date}.sql";
print "cmd: $cmd\n";
#system( $cmd );

my $cmd = "tar -czvf ${backups}bugs-${date}.tar.gz ${backups}bugs-${date}.sql";
print "cmd: $cmd\n";

#system( $cmd );


