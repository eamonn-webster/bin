use strict;

  if ( opendir( DIR, "." ) ) {
    my $file;
    while ( defined( $file = readdir(DIR) ) ) {
      if ( $file ne lc $file ) {
        rename( $file, lc $file );
      }
    }
    closedir(DIR);
  }
