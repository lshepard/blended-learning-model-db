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

/html
  /iframe/iframe.html - main static page to be embedded in Wordpress site
  /index.html - proxy page for use in testing
  /datatables - DataTable, an open source Javascript library for filtering/sorting/displaying data
  /select2    - Select2, an open source Javascript library that provides dropdowns
  /js - custom Javascript that powers the app


Data Processing (Model)
-----------------------

To scrape the site into the database, run the following:

  bin/scrape.rb

That will download all the data fresh from Innosight and dump it into a Cloudant database associated
with my Heroku account.

To view the contents of the database, visit the following page in your browser:

  http://localhost:5000/data/innosight.json

