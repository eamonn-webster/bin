#
# File: chkchkouts.pl
# Author: eweb
# Copyright WBT Systems, 1995-2009
# Contents:
#
# Date:          Author:  Comments:
#  6th Jan 2009  eweb     #00008 Checkouts

use strict;
use Socket;
use Win32API::Net;

my $sendMail = 1;
my $sendToSelf = 0;
my $limit = 0;

$sendMail = 0;
$sendToSelf = 1;

my $me     = lc($ENV{USERNAME});
my $from   = "Clearcase Checkout Checker<$me\@wbtsystems.com>";
my $reply  = "Clearcase Checkout Checker<$me\@wbtsystems.com>";
my $smtp   = "smtp.dublin.wbtsystems.com";
my $server = $ENV{LOGONSERVER};
my $host   = lc $ENV{COMPUTERNAME};
my $viewdir;

$smtp = "nullmail.wbt.wbtsystems.com";

# need a view...
# so find a view on the current machine...

ChangeToAView();

my $cmd = "cleartool lsco -avobs -fmt \"%u\\t%Ad\\t%d\\t%Rf\\t%Tf\\t%n\\t%Fu\\n\"";

my @checkouts;

my $listall = 0;

print "$cmd\n";

if ( open( COS, "$cmd |") ) {
  while( <COS> ) {
    chomp;
    #my ($user, $date, $file) = split( /\t/ );
    #print "$date $user $file\n";
    @checkouts = (@checkouts, $_);
  }
  close( COS );
}

@checkouts = sort(@checkouts);
my $prevuser;
my $prevname;
my $message;
my $qviewdir = quotemeta( $viewdir );
print "\$qviewdir: $qviewdir\n";
foreach ( @checkouts ) {
  my ($user, $days, $date, $reserved, $view, $file, $name) = split( /\t/ );
  $file =~ s!^$qviewdir!!;
  if ( $user ne $prevuser ) {
    if ( $message ) {
      my $first = (split( / /, $prevname ))[0];
      $message = "$first,\n\n"
               . "The following files have been checked out unreserved for more than $limit days\n"
               . "View\t\tDays\tDate\t\t\tFile\n"
               . $message
               . "\n"
               . "If you have any problems e.g. you can't find the checkout or the view is no longer accessible, give me a shout.\n"
               . "eweb\n";
      my $email = EmailAddr( $prevuser, $prevname );
      SendMail( $email, "Clearcase checkouts", $message );
    }
    $message = undef;
    $prevuser = $user;
    $prevname = $name;
  }
  if ( $reserved eq "reserved" && $days > $limit ) {
    $message = $message . "$view\t$days\t$date\t$file\n";
  }
  elsif ( $listall ) {
    print "$user\t$view\t$days\t$date\t$file\n";
  }
}

sub EmailAddr( $$ ) {
  my ( $user, $name ) = @_;
  my $email = $name . "\@wbtsystems.com";
  #$email = $name . "\@xyz.com";
  if ( $sendToSelf ) {
    $email = "$me\@wbtsystems.com";
  }

  $email =~ s! !.!g;

  return "$name <$email>";
}

sub SendMail( $$$ ) {
  my ($to, $subject, $body ) = @_;
  print "\n$to\n$body";
  if ( $sendMail ) {
    #SendMail2( $from, $reply, $to, $smtp, $subject, $body);
  }
}

sub SendMail2($$$$$$) {
  my ($From, $Reply, $To, $SMTP, $Subject, $Message) = @_;

  my $FromAddr  = $From;
  my $ReplyAddr = $Reply;

  #$To =~ s/[ \t]+/, /g;              # replace spaces and tabs with comma
  $FromAddr  =~ s/.*<([^\s]*?)>/$1/; # get from email address
  $ReplyAddr =~ s/.*<([^\s]*?)>/$1/; # get reply email address
  $Message =~ s/^\./\.\./gm;         # handle . as first character
  $Message =~ s/\r\n/\n/g;           # replace CR\LF with just LF
  $Message =~ s/\n/\r\n/g;           # replace LF\CR with just LF
  $SMTP =~ s/^\s+//g;                # remove spaces at start of $SMTP
  $SMTP =~ s/\s+$//g;                # remove spaces at end of $SMTP

  if ( !$To ) {
    print "ERROR: None one to send to $To\n";
    return -8;
  }

  my ($Protocol) = (getprotobyname('tcp'))[2];
  my ($Port)     = (getservbyname('smtp', 'tcp'))[2];

  # need to look at the smtp host specified - if it's in numeric format (eg 127.0.0.0) then we need
  # to pack the 4 digit groups into a binary character format.
  # Otherwise a hostname is specified (eg Yeager) so we call gethostbyname() function to return the
  # network address in the same format as the pack() function.
  my ($SMTPAddr) = ($SMTP =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/) ? pack('C4',$1,$2,$3,$4)
                            : (gethostbyname($SMTP))[4];

  if ( !defined($SMTPAddr) ) {
    print "ERROR \$SMTPAddr: $SMTPAddr, \$SMTP: $SMTP\n";
    return -1;
  }

  if ( !socket(MySocket, AF_INET, SOCK_STREAM, $Protocol) ) { # Create the socket
    print "error creating socket!\n";
    return -2;
  }

  if ( !connect(MySocket, pack('Sna4x8', AF_INET, $Port, $SMTPAddr) ) ) { # Open the connection
    print "error (-3) opening connection!\n";
    return -3;
  }

  # Set the Comms socket as the default filehandle
  my ($OldFH) = select(MySocket);

  # flush the socket after every print to the socket
  $| = 1;
  select($OldFH);

  $_ = <MySocket>;
  if ( /^[45]/ ) {
    print "error (-4) opening connection!\n";
    close MySocket;
    return -4;
  }

  # identify ourselves to the SMTP server
  print MySocket "helo localhost\r\n";
  $_ = <MySocket>;
  if ( /^[45]/ ) {
    print "error (-5.1) opening connection!\n";
    close MySocket;
    return -5;
  }

  # Start sending the e-mail message.
  print MySocket "mail from: <$FromAddr>\r\n";
  $_ = <MySocket>;
  if ( /^[45]/ ) {
    print "error (-5.2) opening connection!\n";
    close MySocket;
    return -5;
  }

  foreach ( split(/;+/, $To) ) {
    if ( /.*<([^\s]*?)>/ ) { # get the email address
      $_ = $1;
    }
    print MySocket "rcpt to: <$_>\r\n";
    $_ = <MySocket>;
    if ( /^[45]/ ) {
      print "error adding recipient! $_\n";
      close MySocket;
      return -6;
    }
  }

  print MySocket "data\r\n";
  $_ = <MySocket>;
  if ( /^[45]/ ) {
    print "error (-5.3) opening connection!\n";
    close MySocket;
    return -5;
  }

  print MySocket "To: $To\r\n";
  print MySocket "From: $From\r\n";
  print MySocket "Reply-to: $ReplyAddr\r\n" if $ReplyAddr;
  print MySocket "X-Mailer: Perl Sendmail\r\n";
  print MySocket "Subject: $Subject\r\n\r\n";
  print MySocket "$Message";
  print MySocket "\r\n.\r\n";

  $_ = <MySocket>;
  if ( /^[45]/ ) {
    print "error (-7) opening connection!\n";
    close MySocket;
    return -7;
  }

  print MySocket "quit\r\n";

  close MySocket;
  return 1;
}

sub ChangeToAView() {
  # cleartool lsview -host %COMPUTERNAME% to find views on this host
  # first with an asterix is running... then need to determine the
  # drive ...
  # or cd into the first sub directory of m:\
  $viewdir = "M:\\${me}_${host}";
  if ( -d $viewdir ) {
    chdir( $viewdir );
  }
  elsif ( -d "M:\\${me}_main" ) {
    $viewdir = "M:\\${me}_main";
    chdir( $viewdir );
  }
  else {
    my $dir = "M:\\";
    if ( opendir( DIR, $dir ) ) {
      my $file;
      while ( defined( $file = readdir(DIR) ) ) {
        my $full = "$dir$file";
        #print "$full\n";
        if ( $file eq "." or $file eq ".." ) {
        }
        elsif ( -d $full ) {
          $viewdir = $full;
          chdir( $viewdir );
          last;
        }
      }
      closedir(DIR);
    }
    else {
      $viewdir = undef;
      print "Failed to open \"$dir\"\n";
    }
  }
}
