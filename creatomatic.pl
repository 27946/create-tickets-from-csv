#!/usr/bin/perl
use REST::Client;
use MIME::Base64;
use Digest::MD5;
#Here are a few values which you can fill out here or during runtime

$portal_url='aswintrial.freshdesk.com';# yourdomain.freshdesk.com

$login_key = 'vayiravan.aswin@gmail.com'; #You many alternately enter your API key here

$password = '9842182432';#You may enter 'X' here within quotes if you have entered API key

$subject="New My Subject ";#put your subject here

$message="My Message ";#put your message here



$file_name='';#path the CSV files with one email in one line

$choice='';#put 1 here for fresh run, put 2 here for resume.

while(1)
{
  if($choice=='')
  {
    print"\nPress 1 to start a fresh run\nPress 2 to resume an interupted run\nPress 3 to exit\n\n";
    $choice=<STDIN>;
    unless(($choice>0&&$choice<4))
    {
      $choice='';
      print"\nEnter a valid choice between 1 and 3\n";
      next;
    }

    if($choice==1)
    {
      $choice='';
      $dir='create_csv_data_folder';

      if(-e $dir&&-d $dir)
      {
        print"\nWARNING!!! A FRESH RUN WILL DELETE SAVED DATA\n";
        print"\nThere seems to be an exisiting directory\nPress 1 to continue with the fresh run\n";
        print"\nElse press any other character to go back to main menu\n";
        $choice=<STDIN>;
        unless($choice==1)
        {
          $choice='';
          next;

        }
        $choice='';

        clean_directory($dir);

      }




      #to do open CSV and return array.
      if($file_name eq '')
      {
        print "\nEnter the name of the CSV file\n";
        chomp($file_name=<STDIN>);
      }


      if(-e $file_name)
      {
        print"\n$file_name exists\n Extraction started\n";



        #TO DO function call for upload tickets
        if($portal_url eq '')
        {
          print"\nEnter the portal URL yoursite.freshdesk.com\n";
          chomp($portal_url=<STDIN>);
        }


        if($login_key eq '')
        {
          print"\nEnter your API key or Email address\n";
          chomp($login_key=<STDIN>);
        }

        if($password eq '')
        {
          print"\nEnter your password if you have entered email of enter X for API key\n";
          chomp($password=<STDIN>);
        }


        initialize($dir,$portal_url,$login_key,$password);
        intialize_rest($portal_url,$login_key,$password);
        $r=extract_from_csv($file_name);

        $count=@$r;

        print"\nNumber of records is $count\n";


        open($fh,'+>'."$dir/".'log.txt');
        close($fh);



          for($i=0;$i<$count;)
          {
             open($fh,'>>'."$dir/".'log.txt');

             $status=create_ticket($$r[$i],$subject,$message);

             open(DATA,'+>'."$dir_name/".'last_successful.txt');
             print DATA "$i";
             close(DATA);

             #To do state save hash

             $save_hash=calc_hash();
             open(DATA,'+>'."$dir_name/".'hash.txt');
             print DATA "$save_hash";
             close(DATA);

             ++$i;
             print $fh "$i $status \n";
             print "$i $status \n";
             close($fh);


          }

          open(DATA,'+>'."$dir_name/".'state.txt');
          print DATA "1";# This is
          close(DATA);


          print"\nAll Records Created\n"





      }

      else
      {
        $file_name='';
        print"\nFile doesnt exist, you will be redirected to main menu\n";
        next;
      }



    }

    if($choice==2)
    {




      $choice='';

      $state='';
      $dir='create_csv_data_folder';

      if(!(-e $dir))
      {
        die "\nNo save data found\n";
      }


      open(DATA,$dir.'/'.'state.txt');
      $state='';

        while(<DATA>)
        {
          $state=$_;
        }
      close(DATA);

        if($state==1)
        {
          print"\nCan not resume as previous run was successful\n";
          next;
        }
        if($state!=0)
        {
          die"\nsave data corrupt\n";
        }

        $current_hash=calc_hash();
        $prev_hash='';
        open(DATA,$dir.'/'.'hash.txt') or die;

          while(<DATA>)
          {
            $prev_hash=$_;
          }
        close(DATA);


        if(!($current_hash eq $prev_hash))
        {
          print("\nDifferent HAsh!\n");
          die "\nStart over, Save Data corrupt";

        }

        open(DATA,$dir.'/'.'url.txt') or die;

          while(<DATA>)
          {
            $portal_url=$_;
          }
        close(DATA);


        open(DATA,$dir.'/'.'login_key.txt') or die;

          while(<DATA>)
          {
            $login_key=$_;
          }
        close(DATA);

        open(DATA,$dir.'/'.'password.txt') or die;

          while(<DATA>)
          {
            $password=$_;
          }
        close(DATA);
        $file_name="$dir".'/'.'data.csv';
        intialize_rest($portal_url,$login_key,$password);
        $r=return_list_from_csv();

        $count=@$r;
        print"\n$count\n";

        open(DATA1,$dir.'/'.'last_successful.txt') or die;

          while(<DATA1>)
          {
            $resume_value=$_;
          }
        close(DATA1);

        print"Need to resume form $resume_value\n";
        $resume_value=$resume_value+1;



          for($i=$resume_value;$i<$count;)
          {


             $status=create_ticket($$r[$i],$subject,$message);
             open(DATA3,'+>'.$dir_name.'/last_successful.txt') or die $!;
             print DATA3 "$i";
             close(DATA3);


             $save_hash=calc_hash();
             open(DATA,'+>'."$dir_name/".'hash.txt') or die;
             print DATA "$save_hash";
             close(DATA);

             ++$i;
             open($fh,'>>'."$dir/".'log.txt') or die;
             print $fh "$i $status \n";
             print "$i $status \n";
             close($fh);


          }

          open(DATA,'+>'."$dir_name/".'state.txt') or die;
          print DATA "1";# This is
          close(DATA);


          print"\nAll Records Created\n"




    }

    if($choice==3)
    {
      $choice='';
      print"\nAre you sure you want to exit?\n Enter 1 to exit\n Else enter any value to go to main menu\n\n";
      $choice=<STDIN>;
      if($choice==1)
      {
        print"\nExiting Program\n";
        exit 1;
      }
      $choice='';


    }

  }



}



sub calc_hash
{
  my $dir='create_csv_data_folder';
  $myDigest = Digest::MD5->new();
  open(DATA1,$dir.'/'.'data.csv');
  open(DATA2,$dir.'/'.'last_successful.txt');
  open(DATA3,$dir.'/'.'login_key.txt');
  open(DATA4,$dir.'/'.'url.txt');
  $myDigest->addfile(DATA1);
  $myDigest->addfile(DATA2);
  $myDigest->addfile(DATA3);
  $myDigest->addfile(DATA4);
  $digest = $myDigest->hexdigest();
  return $digest;
  close(DATA1);
  close(DATA2);
  close(DATA3);
  close(DATA4);

}



#This function would remove a directory and its sub FILES only, args: dir_name
sub clean_directory
{
 $dir_name=$_[0];
 my @files = glob( $dir_name.'/*' );
 $size= scalar @files;
 if($size!=0)
 {
   foreach (@files )
   {
      unlink($_);
   }

 }
 rmdir($dir_name);

}#end clean_directory




#This function takes in dirname,portal_url,login_key,password and saves it to file for resume mode.
sub initialize
{
 $dir_name=$_[0];
 my $url=$_[1];
 my $login_key=$_[2];
 my $password=$_[3];

 mkdir($dir_name);
 open(DATA,'+>'."$dir_name/".'url.txt');
 print DATA "$url";
 close(DATA);
 open(DATA,'+>'."$dir_name/".'login_key.txt');
 print DATA "$login_key";
 close(DATA);
 open(DATA,'+>'."$dir_name/".'password.txt');
 print DATA "$password";
 close(DATA);
 open(DATA,'+>'."$dir_name/".'state.txt');
 print DATA "0";
 close(DATA);
}



#This function takes a valid file name as input and returns the contents as an array

sub extract_from_csv
{

 my $file_name=$_[0];

 my $dir_name='create_csv_data_folder';

 open(DATA1, $file_name)or die;

 open(DATA2, '+>'."$dir_name/".'data.csv') or die;

 while(<DATA1>)
 {
    print DATA2 $_;
 }
 close( DATA1 );
 close(DATA2);

 open(DATA,"$dir_name/".'data.csv');

 @list;

   while(<DATA>)
   {
       chomp($cur=$_);
       push(@list,$cur);
   }



  close(DATA);
  return \@list;


}

#This function intializes the REST modules, argsuments portal_url,$email_id,$password
sub intialize_rest
 {
   my $portal_url=$_[0];

   my $key=$_[1];

   my $password=$_[2];

   $client = REST::Client->new();

   $client->setHost("http://$portal_url");

   $client->addHeader('Content-Type', 'application/json');

   $client->addHeader('charset', 'UTF-8');

   $client->addHeader("Authorization", "Basic ".encode_base64("$key:$password"));

   print"\n\Rest intialize successful\n";

 }

#This function creates tickets and returns status codes. args email,subject,message
sub create_ticket
 {

   my $email=$_[0];
   my $subject=$_[1];
   my $message=$_[2];
   my $req="
         {
           \"helpdesk_ticket\":{
               \"description\":\"$message\",
               \"subject\":\"$subject\",
               \"email\":\"$email\",
               \"priority\":1,
               \"status\":2
           }
         }";
   $client->POST("/helpdesk/tickets.json",$req);
   return $client->responseCode();


 }

#converts CSV file to array
sub return_list_from_csv
{
  open(DATA,"create_csv_data_folder/".'data.csv');

  @list;

    while(<DATA>)
    {
        chomp($cur=$_);
        push(@list,$cur);
    }

   close(DATA);
   return \@list;

}
