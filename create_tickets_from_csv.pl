use REST::Client;
use MIME::Base64;
=begin
This script makes use of Freshdesk's API http://freshdesk.com/api
This perl script would read E-mails from a CSV file and raise tickets on behalf of the emails read from the CSV file.
=cut

$portal_url='';# yourdomain.freshdesk.com

$email_id = ''; #You many alternately enter your API key here

$email_pass = '';#You may enter 'X' here within quotes if you have entered API key

$client = REST::Client->new();

$message="My Message ";#put your message here
$subject="New My Subject ";#put your subject here

$file_name='mock.csv';#path the CSV files with one email in one line

open(DATA,$file_name);

@list;

while(<DATA>)
{
  chomp($cur=$_);
  push(@list,$cur);
}
print "Counting\n";
$count=@list;

print"The # of tickets that will be created $count\n";

$client->setHost("https://$portal_url");
$client->addHeader('Content-Type', 'application/json');
$client->addHeader('charset', 'UTF-8');
$client->addHeader("Authorization", "Basic ".encode_base64("$email_id:$email_pass"));


for($i=0;$i<$count;$i++)
{
  $email="$list[$i]";
  $req="
  {
    \"helpdesk_ticket\":{
        \"description\":\"$message\",
        \"subject\":\"$subject\",
        \"email\":\"$email\",
        \"priority\":1,
        \"status\":2
    },
    \"cc_emails\":\"diaena\@freeshdesk.com\"
  }";


  #my $response = $client->POST("/helpdesk/tickets.json",$req);
  $client->POST("/helpdesk/tickets.json",$req);
}



close(DATA);
