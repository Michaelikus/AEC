#!/usr/bin/perl

use Asterisk;
use Asterisk::AMI;
use EV;
use DBI;
use DBD::Pg;

#my $COMMIT_value        = 2000;

my $DBuser      = '';
my $DBpass      = '';

my $str, $query;



my $astman = Asterisk::AMI->new(
		PeerAddr => '', 
		PeerPort => '', 
		Username => '', 
		Secret => '',
		Events => 'on',
		Handlers => { default => \&eventhandler } 
		);
#Alternatively you can set Blocking => 0, and set an on_error sub to catch connection errors
die "Unable to connect to asterisk" unless ($astman);


#Define the subroutines for events
sub eventhandler { 
 my ($ami, $event) = @_; 
 my $EventMnemo = $event->{'Event'};

 if(!$dbh){
   my $dbh = DBI->connect("dbi:Pg:dbname=logs;host=10.0.1.11;port=5432;",
        $DBuser,
        $DBpass,
        {AutoCommit => 0, RaiseError => 1, PrintError => 0});
 }

 $query = "";
 $json_str = "";

 $query = "insert into events_list(event_name, event_value) values('$EventMnemo',";

 while (($k, $v) = each %$event) {
   if($json_str eq ""){
   } else {
     $json_str = $json_str . "\,";
   }
   $json_str = $json_str . "{\"event_key\":\"$k\"\, \"event_value\":\"$v\"}";
 }
 $query = $query . "'[" . $json_str . "]');\n";
 #print "$query";

 my $sth = $dbh->prepare($query);
    $sth->execute;
    $dbh->commit;
 }
}

#Start our loop
EV::loop;

while(1){}
