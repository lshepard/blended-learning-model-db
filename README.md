blended-learning-model-db
=========================

This is a simple script that scrapes the Innosight Blended Learning Database and
formats the data for easy filtering and sorting.

== Scraper ==

Set up your Perl environment:

 cpan install Web::Scraper
 cpan install JSON
 cpan install Data::Dumper

Then to run the scraper:

 perl scraper.pl > html/js/innosight_data.js 

== Website ==

To view the website, just plop the html directory in a webserver. Make sure the innosight_data.js
file is in place first. There's no server-side code.
