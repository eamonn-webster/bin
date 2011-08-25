use strict;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;
use File::Basename;

my $ua;
my $uaTIMEOUT = 18000;

my $host = "http://documentation.spicelogic.com";
my $site = "$host/Products/WinHTMLEditorControl";
my $start = "Default.html";
my $dest = "c:/temp/WinHTMLEditorControl";

sub MkDir($) {
  my ($dir) = @_;
  if ( -d $dir ) {
    #print "MkDir $dir exists\n";
  }
  else {
    my $sofar = "";
    foreach ( split( /[\\\/]/, $dir ) ) {
      if ( $sofar eq "" ) {
        $sofar = $_;
      }
      else {
        $sofar = osify("$sofar/$_");
        if ( -d $sofar ) {
          #print "MkDir $sofar exists\n";
        }
        else {
          #print "calling mkdir( $sofar )\n";
          if ( mkdir( $sofar ) ) {
            #print "MkDir $dir succeeded\n";
          }
          else {
            print "MkDir $sofar FAILED! $!\n";
            return 0;
          }
        }
      }
    }
    #print "MkDir $dir\n";
  }
}



sub osify($)
{
  my ($path) = @_;
  if ( $^O eq "MSWin32" )
    {
      $path =~ s!/!\\!g;
    }
  else
    {
      $path =~ s!\\!/!g;
    }
  return $path;
}

system( "rd /s /q \"$dest\"");
MkDir($dest);

if ( !$ua )
  {
    $ua = new LWP::UserAgent;
    $ua->timeout($uaTIMEOUT);   # number of seconds before User Agent times out
  }

my %pages;

$pages{$start} = 0;

sub add($$) {
  my ($page, $referer) = @_;
  if ( $page =~ /\.exe/ ) {
    $pages{$page} = -1;
    #print "Don't add exes\n";
    return;
  }
  if ( $page =~ /^javascript:/ ) {
    $pages{$page} = -1;
    #print "Don't add javscript link\n";
    return;
  }
  if ( $page =~ /^file:/ ) {
    $pages{$page} = -1;
    #print "Don't add local file refs\n";
    return;
  }
  if ( $page =~ /^mailto:/ ) {
    $pages{$page} = -1;
    #print "Don't add mailto refs\n";
    return;
  }

  if ( $page =~ m!http://msdn2.microsoft.com! or $page =~ m!http://msdn.microsoft.com! ) {
    $pages{$page} = -1;
    #print "Don't add msdn\n";
    return;
  }

  if ( $page =~ /^http:/ ) {
    if ( $page =~ /spicelogic.com/i ) {
    }
    else {
      #print "wrong domain\n";
      return;
    }
  }
  if ( $referer =~ m!^$site/(.+)/[^/]+$! ) {
    #print "REFER: $page => $1/$page\n";
    $page = "$1/$page";
  }
  if ( $page =~ /#(.+)$/ ) {
    $page = $1;
  }
  if ( $pages{$page} eq "" ) {
    $pages{$page} = 0;
  }
}
sub get($$) {
  my $addStatus = 1;
  my ($site,$page) = @_;
  my $url = "$site/$page";
  if ($page =~ /^http:/) {
    #$page =~ s!$site!!;
    $url = $page;
    if ($page =~ m!/([^/]+)$! ) {
      print "$page => $1\n";
      $page = $1;
    }
  }
  elsif ($page =~ /^\//) {
    #$page =~ s!$site!!;
    $url = "$host$page";
    if ($page =~ m!/([^/]+)$! ) {
      print "$page => $1\n";
      $page = $1;
    }
  }

  print "GET $url\n";

  my $request = new HTTP::Request("GET", $url);
  my $response = $ua->request($request);
  #print $response->status_line . "\n";
  if ( $response->code eq 404 )
    {
      print $response->status_line . "\n";
      #print "ERROR: " . $response->headers_as_string . "\n";
    }
  elsif ( $response->code ne 200 )
    {
      print $response->status_line . "\n";
      print "ERROR: " . $response->headers_as_string . "\n";
    }
  else
    {
      #my $headers = $response->headers_as_string;
      my $contentType = $response->header( "Content-type" );
      if ( $contentType )
        {
          my $ext;
          $ext = ".html" if ( lc $contentType =~ "text/html" );
          $ext = ".txt" if ( lc $contentType =~ "text/plain" );
          $ext = ".xml" if ( lc $contentType =~ "text/xml" );
          $ext = ".js" if ( lc $contentType =~ "text/javascript" );
          $page =~ s!\.html$!$ext!;
          if ( $page =~ /WebResource\.axd\?(.+)/ ) {
            $addStatus = $page;
            $page =~ s![\?&=;]!_!g;
            $page = $page . $ext;
          }
          my $file = osify("$dest/$page");
          if ( -e $file) {
            print "Already downloaded $file\n";
          }
          else {
            my ($name, $dir) = fileparse($file);
            #print "Checking directory $dir\n";
            if ( ! -d $dir ) {
              print "Creating directory $dir\n";
              MkDir( "$dir" );
            }
            if ( open( OUT, ">$file" ) ) {
              print "Writing $file\n";
              print OUT $response->content;
              close (OUT);
              if ( open( IN, $file ) ) {
                #print "Opened $file\n";
                while ( <IN> ) {
                  if ( /href=(')([^']+)\1/ ) { #"'
                    add($2, $url);
                  }
                  elsif ( /href=(")([^"]+)\1/ ) { #"'
                    add($2, $url);
                  }
                  elsif ( /src=(')([^']+)\1/ ) { #"'
                    add($2, $url);
                  }
                  elsif ( /src=(")([^"]+)\1/ ) { #"'
                    add($2, $url);
                  }
                }
                close (IN);
              }
            }
            else {
              print "Couldn't open $file\n";
            }
          }
        }
      else
        {
          print "ERROR no type: " . $response->headers_as_string . "\n";
        }
    }
  $pages{$page} = $addStatus;
}

my $keepGoing = 1;
while ( $keepGoing ) {
  $keepGoing = 0;
  foreach ( keys %pages ) {
    #print "Considering $_\n";
    if ( $pages{$_} eq 0 ) {
      $keepGoing = 1;
      get( $site, $_ );
    }
  }
}
