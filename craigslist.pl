#This script fetches the last 2 days new job postings from craigslist that match  
#a specific criteria and reports the URLs that correspond to that match.
#The search criteria comes from the input arguments. The cragislist sites
#are hardwired to the New England area. You may change them by manually 
#altering the variables in Section #3.
#
#Version 0.2 30/march/2012
#Author: Nuno Alves
#
#############################################################################
#Section #1 - load libraries
#############################################################################
use strict;
use POSIX;
use LWP::Simple;

#############################################################################
#Section #2 - input arguments are your skillsets
#############################################################################
my $num_args = $#ARGV + 1;
if ($num_args == 1) { print "You must add some skills as arguments\n"; exit; }

#############################################################################
#Section #3 - defining variables
#############################################################################
#what cragislist sites 
my @search_site=("http://boston.craigslist.org","http://nh.craigslist.org","http://maine.craigslist.org","http://burlington.craigslist.org","http://westernmass.craigslist.org","http://worcester.craigslist.org");

#type what positions you are looking for (egr = engineering, sof = software)
my @positions=("egr","sof","bus","acc");

#this array contains the arguments which are your resume skills
my @skills=@ARGV ;

#############################################################################
#Section #4 - debug code
#############################################################################
#instead of work on every single URL, setting $debug=1, will just scan
#two webpages
my $debug=0; 
my @debug_urls=("http://boston.craigslist.org/gbs/egr/2902012136.html","http://boston.craigslist.org/bmw/egr/2929181526.html","http://boston.craigslist.org/gbs/egr/2926742528.html");

#############################################################################
#Section #5 - subroutines for collecting craigslist data
#############################################################################
sub collect_job_posting_http
{
	my $url=$_[0];
	my $content = get $url;
	
	#print $content . "\n";
	my @splitcontents=split(/<h4 class=\"ban\"/,$content);
	my $size_splitcontents=@splitcontents;
	
	my @url_data=();
	for (my $i=1 ; $i<$size_splitcontents ; $i++)
	{
		#just want the last 2 days of postings
		if ($i<3) 
		{
			#print "============\n\n\n";
			#print $splitcontents[$i] . "\n";
		
			#get all the posting urls for this particular day
			my @postingdata=split(/<p><a href=\"|\">/,$splitcontents[$i]);
	
			for (my $j=0; $j<@postingdata ; $j++)
			{	
				#print ">>[$j]>>" . $postingdata[$j] . "<<<\n";
				if ($postingdata[$j]=~m/^http/) 
				{
					push(@url_data,$postingdata[$j]);
				}
			}
		}
	}

return(@url_data);	
}


sub extract_date
{	
	my @url_data=$_[0];
	my @date_data=split(/Date: 2012-|EDT<br>/,$url_data[0]);	

	return("2012-" . $date_data[1]);
}

#############################################################################
#Section #6 - main program: collecting http data for each job posting
#############################################################################
my @urls=();


if ($debug == 0)
{
	for (my $k=0;$k<@search_site;$k++)
	{
		for (my $z=0;$z<@positions;$z++)
		{
			my $base_url=$search_site[$k]."/".$positions[$z];
			my @tmp_data=collect_job_posting_http $base_url;
			push(@urls,@tmp_data);
		}
	}
}
else
{
	@urls=@debug_urls;
}

#foreach (@urls)
#{
#	print $_ . "\n";
#}


#############################################################################
#Section #7 - check if each posting matches at least one skill
#############################################################################
my @matched_skills=();
my @skill_type=();
my @post_date=();

for (my $i=0 ; $i<@urls ; $i++)
{
	my $url=$urls[$i];
	my $content = get $url;
	my $counter=0;
	my $date;
	
#	print $url . "\n";
#	print $content . "\n";
	
	my $skill_type_desc="";

	for (my $k=0; $k<@skills ; $k++)
	{
		if ($content =~ m/$skills[$k]/i) 
		{ 
			$counter++; 
			$skill_type_desc = $skill_type_desc . $skills[$k] . " ";
		}	
	}
	push(@matched_skills,$counter);
	push(@skill_type,$skill_type_desc);
	push(@post_date,extract_date($content));
}

#############################################################################
#Section #8 - print results to the screen
#############################################################################
for (my $i=0; $i < @matched_skills ; $i++)
{
	if ($matched_skills[$i]>0)
	{ 
		print "<li><a href=\"$urls[$i]\">site #$i\<\/a\>" . "!" . $post_date[$i] . "!" . $matched_skills[$i] . "!" . $skill_type[$i] . "\n"; 
	}
}
