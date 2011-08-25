#******************************************************************************/
#
#  File: tctest.pl
#  Author: eweb
#  Copyright WBT Systems, 2006-2007
#  Contents:
#
#******************************************************************************/
#
#   Date:          Author:  Comments:
#   23rd Jan 2007  eweb     Some test cases.
#   25th Jan 2007  eweb     Command line args, error handling.
#

use strict;

use Getopt::Std;
use File::Basename;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;
use HTML::Form;
use HTTP::Request::Common qw(POST);

my $Major;
my $Minor;
my $Point;
my $Build;
my $ua;
my $uaTIMEOUT = 18000;
my $CONNID;
my @COOKIES;
my $theUser;

my $TCHOST = "http://localhost";
my $TCDLL = "topclass.dll";
my $TCDIR = "/topclass/";

if ( lc $ENV{COMPUTERNAME} eq "roo" )
  {
    $TCDIR = "/tc742/";
    $TCDLL = "tce742iis.dll";
  }
if ( lc $ENV{COMPUTERNAME} eq "hogfather" )
  {
    $TCDIR = "/tc742cc/";
    $TCDLL = "tce742iis.dll";
  }

if ( $^V and $^V lt v5.8.0 )
  {
    die "This script requires perl 5.8.0 or greater\n";
  }

my %opts = ( i => undef(),
             g => undef(),
             p => undef(),
             u => undef(),
             d => undef(),
             h => undef(),
           );

# Was anything other than the defined option entered on the command line?
if ( !getopts("i:g:p:u:d:h:", \%opts) or @ARGV > 1 )
  {
    print STDERR "Unknown arg @ARGV\n" if @ARGV > 0;
    #Usage();
    exit;
  }

if ( defined $opts{u} )
  {
    $TCDIR = $opts{u};
    if ( $TCDIR eq "/" )
      {
      }
    elsif ( $TCDIR =~ /^\/.*\/$/ )
      {
      }
    else
      {
        die "-u arg should start and end in a slash e.g. /topclass/ \n";
      }
  }
if ( defined $opts{d} )
  {
    $TCDLL = $opts{d};
  }
if ( defined $opts{h} )
  {
    $TCHOST = $opts{h};
    if ( $TCHOST =~ /http:/ || $TCHOST =~ /https:/ )
      {
      }
    else
      {
        $TCHOST = "http://$TCHOST";
      }
  }

my $TCURL  = "$TCHOST$TCDIR";
my $TCPATH = "$TCHOST$TCDIR$TCDLL";

if ( !$ua )
  {
    $ua = new LWP::UserAgent;
    $ua->timeout($uaTIMEOUT);   # number of seconds before User Agent times out
  }

# New in 7.4.2
#?login-admin-admin-cmd=about%2Dxml
sub getAbout ()
  {
    my $theURL = "${TCPATH}?about";
    print "GET $theURL\n";
    my $request = new HTTP::Request("GET", $theURL);
    $request->header("Content-type" => "text/XML");
    $request->header("Accept" => "text/*");
    my $response = $ua->request($request);
    #print $response->status_line . "\n";
    if ( $response->code ne 200 )
      {
        print $response->headers_as_string . "\n";
        return 0;
      }
    else
      {
        #my $headers = $response->headers_as_string;
        my $contentType = $response->header( "Content-type" );
        if ( $contentType )
          {
            if ( lc $contentType eq "text/html" ||
                 lc $contentType eq "text/xml" )
              {
                my $content = $response->content();
                if ( $content =~ /<Version>(.*)<\/Version>/ )
                  {
                    print "$1\n";
                    return 1;
                  }
                elsif ( $content =~ /<Code>-1<\/Code>/ )
                  {
                    if ( $content =~ /<DetailedMsg>(.*)/ )
                      {
                        print "$1\n";
                      }
                    else
                      {
                        print "$content\n";
                      }
                  }
                elsif ( $content =~ /^</ )
                  {
                    print "$content\n";
                  }
              }
            elsif ( lc $contentType eq "text/plain" )
              {
                print $response->headers_as_string . "\n";
                my $content = $response->content();
                #if ( $content =~ /^</ )
                  {
                    print "$content\n";
                  }
              }
            else
              {
                print $response->headers_as_string . "\n";
              }
          }
        else
          {
            print $response->headers_as_string . "\n";
          }
      }
    return 0;
  }

sub logout()
  {
    if ( $ua && $CONNID )
      {
        my $theURL = "${TCPATH}?Conn-$CONNID-Logout";
        my $request = new HTTP::Request("GET", $theURL);
        SetCookies( $request );
        my $response = $ua->request($request);

        $CONNID = "";
        @COOKIES = ();
        print "User $theUser logged out\n";
      }
  }

# cleanup()
#   Log the fact that we are stopping.
#

sub cleanup()
  {
  }

sub login($$)
  {
    my ( $username, $password ) = @_;
    $theUser = $username;
    #print "Need to log in<br>\n";
    if ( $username eq "" or $password eq "" )
      {
        print "Need both a username and a password to log in<br>\n";
        cleanup();
        die "Cannot login, Username and password required";
      }
    if ( !$ua )
      {
        $ua = new LWP::UserAgent;
        $ua->timeout($uaTIMEOUT);   # number of seconds before User Agent times out
      }
    my $theURL = "${TCPATH}?Login-$username-$password-really";

    print "Using $theURL\n";

    my $request = new HTTP::Request("GET", $theURL);
    my $response = $ua->request($request);
    my $headers = $response->headers_as_string();
    #print "$headers\n";
    my $content = $response->content();

    HandleCookies( $headers );

    if ( $content =~ /Conn-(................)/ )
      {
        $CONNID = ($1);
        print "User $username logged in connection $CONNID\n";
        #print "User $username logged in<br>\n";
      }
    elsif ( $content =~ /Already logged in/ )
      {
        print "$username is already logged in<br>\n";

        print "FAIL\tUser $username is already logged in\n";
        cleanup();
      }
    else
      {
        print "FAIL\tCould not obtain connection ID\n";
      }


    #print "Have logged in as $username<br>\n";
  }

sub HandleCookies( $ )
  {
    my ( $headers ) = @_;

    @COOKIES = ( $headers =~ /Set-Cookie: (.*)/g );

    if ( $#COOKIES + 1 > 0 )
      {
      }
    else
      {
        #print "FAIL\tCould not get new cookie\n$headers\n";
        #logout();
        cleanup();
        die "Could not get new cookie\n$headers\n";
      }
  }

sub SetCookies( $ )
  {
    my ( $req ) = @_;
    for my $cookie (@COOKIES)
      {
        $req->header(Cookie => $cookie);
      }
  }

sub editUser( $ )
  {
    my ( $username ) = @_;

    my $arg = $username;

    $arg =~ s/-/%2D/g;

    my $theURL = "${TCPATH}?Conn-$CONNID-Edit-user-$arg";

    print "Using $theURL\n";

    my $request = new HTTP::Request("GET", $theURL);
    my $response = $ua->request($request);
    my $headers = $response->headers_as_string();
    HandleCookies( $headers );
    my $content = $response->content();

  }

sub ExistsInTopClass( $$$ )
  {
    my ($name, $type, $content) = @_;
    #encode hyphens...
    my $arg = $name;
    $arg =~ s!-!%2D!g;
    my $theURL = "${TCPATH}?Conn-$CONNID-Edit-$type-$arg";

    print "$theURL\n";

    my $request = new HTTP::Request("GET", $theURL);
    SetCookies( $request );
    my $response = $ua->request($request);
    my $headers = $response->headers_as_string;
    $$content = $response->content();

    HandleCookies( $headers );

    if ( $$content =~ /could not be found/ or $$content =~ /does not exist/ )
      {
        return 0;
      }
    else
      {
        return 1;
      }
  }

sub updateUser( $% )
  {
    my ( $content, %updates ) = @_;

    my $form = HTML::Form->parse( $$content, $TCURL );
    if ( !$form )
      {
        print "No edit-user form\n";
        #print "****\n$$content\n****\n";
      }
    else
      {
        #print "Have edit-user form\n";
        #print "****\n$$content\n****\n";
        #$form->dump();
        my $updateNeeded = 0;
        foreach my $key ( keys( %updates ) )
          {
            my $value = $updates{$key};
            #print "$key = $value\n";
            if ( !$form->find_input( $key ) )
              {
                print "Not on form $key\n";
              }
            elsif ( $form->value( $key ) eq $value )
              {
                #print "No change in value $value<br>\n";
              }
            else
              {
                $form->value( $key, $value );
                $updateNeeded = 1;
              }
          }
        if ( $updateNeeded eq 1 )
          {
            print "Modifying user\n";
            #my $request = POST $theCommand, [$theForm->form, $theOption => $theValue ];
            my $request = $form->click( "modif" );
            SetCookies( $request );
            my $response = $ua->request($request);
            my $theContent = $response->as_string;
            my $headers = $response->headers_as_string;

            HandleCookies( $headers );
          }
        else
          {
            print "No changed needed for user\n";
          }
      }
  }

if ( getAbout() )
  {
    login( "admin", "admin" );

    my $userform;
    if ( ExistsInTopClass( "instructor", "user", \$userform ) )
      {
        #print "****\n$userform\n****\n";
        my %updates = ( EditClasses => 65536,
                        EditPages => 32768,
                        AssignToUser => 560,
                      );
        updateUser( \$userform, %updates );
        logout();

        login( "instructor", "instructor" );
        logout();
      }
    else
      {
        logout();
      }
  }
