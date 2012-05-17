#!/usr/bin/perl
#
# This script does a simple scrape on the Innosight web page to get 
# the set of models. It outputs the JSON structure as a valid
# JavaScript file to STDOUT.
#
# Suggested usage:
#
#    perl scraper.pl > models.js
#
# Optionally, add a limit to the number of schools scraped. This
# is useful for quick iteration when testing. For example, to only
# pull three schools, run:
#
#    perl scraper.pl 3
#

use warnings;
use strict;
use URI;
use Web::Scraper;
use Data::Dumper;
use JSON;

my $json = JSON->new->pretty;
my $limit = $ARGV[0] ? $ARGV[0] : 1000;

#
# Step 1: scrape the list of pages
# If you see "Found 0 urls" message, then the scraper CSS expression
# probably needs to be updated.
#
sub fetch_list_of_school_models() {

    my $source_uri = "http://www.innosightinstitute.org/media-room/publications/blended-learning/blended-learning-profiles-all-profiles/";
    
    my $link_scraper = scraper {
	process 'div.entry > div > strong > p > a', "urls[]" => '@href';
    };
    
    print STDERR "Scraping $source_uri\n";
    my $res = $link_scraper->scrape(URI->new($source_uri));

    print STDERR "Found " . @{$res->{urls}} . " urls.\n";
    return $res->{urls};
}

#
# Step 2: for each school, scrape the info from it
#
sub scrape_data_per_page {
    my ($url) = @_;

    my $individual_page_scraper = scraper {
        # Title fields, before the first big table
	process "div.post > h2", 'title' => 'TEXT';
	process "div.post > div.entry > p > span", 'detail' => 'TEXT';
	process "div.post > div.postdate", 'postdate' => 'TEXT';

        # These fields all come from the table at the top of the page
	process '//td[.="Headquarters"]/following-sibling::td[1]', 'hq' => 'TEXT';
	process '//td[.="Operator type"]/following-sibling::td[1]', 'type' => 'TEXT';
	process '//td[.="Focus"]/following-sibling::td[1]', 'focus' => 'TEXT';
	process '//td[.="Grades served"]/following-sibling::td[1]', 'gradesserved' => 'TEXT';
	process '//td[.="Blended grades"]/following-sibling::td[1]', 'blendedgrades' => 'TEXT';
	process '//td[.="Enrollment"]/following-sibling::td[1]', 'blendedenrollment' => 'TEXT';
	process '//td[.="Blended subjects"]/following-sibling::td[1]', 'blendedsubjects' => 'TEXT';

        # Info extracted from the free-text fields
        process '//div/p[strong[contains(.,"Program model:")]]/text()', 'programmodels' => 'TEXT';
    };

    # Fetch the webpage and do the scraping
    print STDERR "Scraping $url\n";
    my $res = $individual_page_scraper->scrape($url);

    # Minor post-processing to make it easier in the Javascript
    $res->{url} = $url->as_string;
    ($res->{hqcity}, $res->{hqstate}) = split(', ?', $res->{hq});
    $res->{postdate} =~ s/Posted on (.*) by .*/$1/;  # strip out verbosity
    $res->{postdate} =~ s/(\d)(st|nd|rd|th)/$1/;     # remove text part of 1st, 2nd, etc for JS Date.parse function
    $res->{programmodels} =~ s/^\s+//;               # remove leading whitespace
    return $res;
}

# main body of script execution

my $links = fetch_list_of_school_models();

my @data = ();
for my $link (@$links[0..$limit]) {
    if ($link) {
        push(@data, scrape_data_per_page($link));
    }
}

print "table_data = " . ($json->encode(\@data));
