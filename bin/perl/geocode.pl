#!/usr/bin/perl
#
# Geocode all the locations pulled in from the innosight scraping.
#
use warnings;
use strict;
use URI;
use JSON;
use Data::Dumper;
use LWP::Simple;

my $json = JSON->new->pretty;

# read in json
my @lines = <STDIN>;
my ($variable, $input) = split(/=/, join('', @lines), 2);
my $data = decode_json $input;
my $output = {};

for my $row (@$data) {
    my $location = $row->{hqcity} . "," . $row->{hqstate};

    # don't repeat
    if ($output->{$location}) {
        next;
    }

    print STDERR "Geocoding " . $location . "\n";
    my $url = "http://maps.googleapis.com/maps/api/geocode/json?sensor=false&address=" . $location;
    my $query_results = decode_json get($url);
    $output->{$location} =
        $query_results->{results}[0]->{geometry}->{location};
    sleep 1;
}

print "locations = " . ($json->encode($output));
