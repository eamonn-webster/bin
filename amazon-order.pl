use strict;

my $filename = "C:\\temp\\amazon-mail.txt";

$filename = "C:\\temp\\mail.google.com.htm";

my $euroTotal;
my $gbpTotal;
my $orderNumber;
my $deliveryEstimate;
my $dispatchEstimate;
my $dateOrdered;
my $artist;
my $title;
my $gbpPrice;
my $currency;
my $quiet;

my @items;

my %MonthIndex = (
  Jan => 1,
  Feb => 2,
  Mar => 3,
  Apr => 4,
  May => 5,
  Jun => 6,
  Jul => 7,
  Aug => 8,
  Sep => 9,
  Oct => 10,
  Nov => 11,
  Dec => 12,
);

my ($Sec, $Min, $Hour, $Day, $Mon, $Year ) = localtime(time);

$Year = $Year + 1900;
$Mon = $Mon + 1;

$dateOrdered = "0 $Day $Mon $Year";

if ( open( ORDER, $filename ) ) {
  print "Opened $filename\n";
  while ( <ORDER> ) {
    #print;
    s!=09!\t!g;
    if ( /Order Grand Total: EUR ([0-9,]+)/ ) {
      $euroTotal = $1;
      $euroTotal =~ s!,!.!;
    }
    elsif ( /Order number:\s+([-0-9]+)/ ) {
      $orderNumber = $1;
    }
    elsif ( /Order #:\s+([-0-9]+)/ ) {
      $orderNumber = $1;
    }
    elsif ( /Total for this order: +GBP ([0-9.]+)/ ) {
      $gbpTotal = $1;
      $gbpTotal =~ s!,!.!;
    }
    elsif ( /Delivery estimate: (.+)/ ) {
      $deliveryEstimate = $1;
    }
    elsif ( /Dispatch estimate for these items: (.+)/ ) {
      $dispatchEstimate = $1;
      #27 May 2011
      if ( $dispatchEstimate =~ /([0-9]+) ([A-Z][a-z]+) ([0-9]+)/ ) {
        $dispatchEstimate = "0 $1 $MonthIndex{$2} $3";
      }
    }
    elsif ( /^\s+1\s+"(.+)"/ ) {
      $title = $1;
    }
    elsif ( /(.+); Audio CD; ([^0-9]+)([0-9.]+)/ && $title ) {
      $artist = $1;
      $currency = $2;
      $gbpPrice = $3;
      my $musicLine = "M \"$title\" \"$artist\" \"amazon.uk\" \"$orderNumber\"";
      $musicLine .= " 0 0 0 0"; # dateReceived
      $musicLine .= " $dateOrdered"; # dateOrdered
      $musicLine .= " 0 0 0 0"; # lastUpdate
      if ( $dispatchEstimate ) {
        $musicLine .= " $dispatchEstimate"; # expected
      }
      else {
        $musicLine .= " 0 0 0 0"; # expected
      }
      $musicLine .= " \"CD\"";
      $musicLine .= " \"Ordered\"";
      $musicLine .= " " . ($gbpPrice * 100) . " 3";
      $musicLine .= " \"Sterling\"";
      @items = (@items, $musicLine);
    }
    elsif ( /Sold by: / ) {
      $artist = undef;
      $gbpPrice = undef;
      $title = undef;
    }
    elsif ( /^In stock/ ) {
    }
    elsif ( /Invoice Address/ or /Delivery Address/ ) {
      $quiet = 1;
    }
    elsif ( $quiet ) {
      if ( /^\s*$/ ) {
        $quiet = undef;
      }
    }
    else {
      print;
    }
  }
  close( ORDER );
}

print ";euroTotal: $euroTotal\n";
print ";orderNumber: $orderNumber\n";
print ";gbpTotal: $gbpTotal\n";
print ";deliveryEstimate: $deliveryEstimate\n";
print ";dispatchEstimate: $dispatchEstimate\n";
foreach ( @items ) {
  print "$_\n";
}
