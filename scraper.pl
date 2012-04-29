#!/usr/bin/perl
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
#
sub get_links() {

    my $source_uri = "http://www.innosightinstitute.org/media-room/publications/blended-learning/blended-learning-profiles-all-profiles/";
    
    my $link_scraper = scraper {
	process 'div.entry > strong > p > a', "urls[]" => '@href';
    };
    
    print STDERR "Scraping $source_uri\n";
    my $res = $link_scraper->scrape(URI->new($source_uri));
    return $res->{urls};
}

#
# Step 2: for each school, scrape the info from it
#
sub get_info_per_page {
    my ($url) = @_;

    my $individual_page_scraper = scraper {
	process "div.post > h2", 'title' => 'TEXT';
	process "div.post > div.entry > p > span", 'detail' => 'TEXT';
	process "div.post > div.postdate", 'postdate' => 'TEXT';
	process '//td[.="Headquarters"]/following-sibling::td[1]', 'hq' => 'TEXT';
	process '//td[.="Operator type"]/following-sibling::td[1]', 'type' => 'TEXT';
	process '//td[.="Focus"]/following-sibling::td[1]', 'focus' => 'TEXT';
	process '//td[.="Grades served"]/following-sibling::td[1]', 'gradesserved' => 'TEXT';
	process '//td[.="Blended grades"]/following-sibling::td[1]', 'blendedgrades' => 'TEXT';
	process '//td[.="Enrollment"]/following-sibling::td[1]', 'blendedenrollment' => 'TEXT';
	process '//td[.="Blended subjects"]/following-sibling::td[1]', 'blendedsubjects' => 'TEXT';
    };

    # scrape the data
    print STDERR "Scraping $url\n";
    my $res = $individual_page_scraper->scrape($url);

    $res->{url} = $url->as_string;
    ($res->{hqcity}, $res->{hqstate}) = split(', ?', $res->{hq});
    $res->{postdate} =~ s/Posted on (.*) by .*/$1/;  # strip out verbosity
    $res->{postdate} =~ s/(\d)(st|nd|rd|th)/$1/;     # remove text in 1st, 2nd, 3rd, 4th
    return $res;
}

my $links = get_links();

for my $link (@$links[0..$limit]) {
    if ($link) {
        push(@data, get_info_per_page($link));
    }
}

print "table_data = " . ($json->encode(\@data));
