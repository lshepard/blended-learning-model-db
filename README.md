blended-learning-model-db
=========================

Why I built this app
====================

The Innosight Institute has put together a fantastic set of research into how blended learning
is being used in K12 schools across America. However, the existing mechanism for organizing all
of that research is a basic Wordpress site. This project is an attempt to improve the situation.

With this app, you can filter, sort, and browse through the Innosight school research.

Getting Started
===============

You can run the app locally as follows

1/ Install packages, and put the install paths in your path.
   git           http://git-scm.com/downloads
   heroku        https://toolbelt.heroku.com/
   ruby 1.9.2    http://www.ruby-lang.org/en/downloads/

2/ Get the software

  git clone blended-learning-model-db

3/ Start the webserver

  cd blended-learning-model-db
  foreman start

4/ In your browser, visit http://localhost:5000 to see it running.

Overview of technologies
========================

The main app is a static HTML page intended to be embedded in an iframe on the Innosight site. All
filtering, sorting, and mapping is done in Javascript on the client, which results in a fast and
snappy interface. We initially scrape the data from the Innosight webpage using a Ruby script.

Javascript (View)
-----------------

The app is mainly just a few open source libraries glued together, with some customized
adapters.

I'm using a few third-party libraries to make this whole thing easier.

 - DataTables (located in html/js/datatables). This library is designed to
   display tabular data and allows for a very configurable filtering, sorting.
   The display is customized to show just the first column, but all the underlying
   management of data is still done with this library.

   My modifications are in html/js/datatables.js.

 - Select2 (located in html/js/select2). Bad-ass open source library for
   the dropdowns.

 - Google Maps (adapter in html/js/maps.js). For mapping the show. Geolocation
   is done in batch in bin/perl/geolocate.pl.


Data Processing (Model)
-----------------------

The info from the Innosight data is scraped into a CloudDB key/value database hosted by
Cloudant. To repopulate the database from scratch, run the following:

  bin/scrape.rb

That will download all the data fresh from Innosight and dump it into a Cloudant database associated
with my Heroku account.

To view the contents, visit the following page in your browser (this is what the JS app uses):

  http://localhost:5000/data/innosight.json

