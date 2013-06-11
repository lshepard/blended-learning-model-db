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

1. Install packages, and put the install paths in your path.

        git           http://git-scm.com/downloads
        heroku        https://toolbelt.heroku.com/
        ruby 1.9.2    http://www.ruby-lang.org/en/downloads/

2. Get the software

        git clone blended-learning-model-db

3. Start the webserver

        cd blended-learning-model-db
        foreman start

4. In your browser, visit ``http://localhost:5000`` to see it running.

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

 - **DataTables** (source located in html/datatables). This library is designed to
   display tabular data and allows for a very configurable filtering, sorting.
   The display is customized to show just the first column, but all the underlying
   management of data is still done with this library.

   My modifications are in html/js/datatables.js.

 - **Select2** (located in html/js/select2). Bad-ass open source library for
   the dropdowns.

 - **Google Maps** (adapter in html/js/maps.js). For mapping the show. 

   Geocodes for current known locations are in html/js/data/geocodes.json. I had written
   a Perl script that generated that, but I deleted it, so you'll need to write
   a geolocater (ideally in Ruby) if you want to add any more locations. You can dig up
   the old version of the Perl script for guidance from the Git history in /bin.


Data Processing (Model)
-----------------------

The info from the Innosight data is scraped into a CloudDB key/value database hosted by
Cloudant. To repopulate the database from scratch, run the following:

    bin/scrape.rb

That will download all the data fresh from Innosight and dump it into a Cloudant database associated
with my Heroku account.

To view the contents, visit the following page in your browser (this is what the JS app uses):

    http://localhost:5000/data/innosight.js


How to do common tasks
======================

* Q. How do I change the language of an autocomplete textbox?

  A. Change the Datatable definition in fnGetColumnsAndData() in html/js/datatable.js.

* Q. Innosight added some new data field. How do I add a new autocomplete textbox for it?
 
  A. Do the following:

  1. Add the new field to the scraper at bin/scrape.rb. If it's nontrivial, then you can
     use irb to figure out the right code to add.

     ```javascript
     result['newfield']     = scrape_row(doc, 'New Field')
     ```

  2. Run the scraper. That dumps the new field into the Cloudant DB.

        $ ruby bin/scrape.rb

  3. Modify the Datatable definition in html/js/datatable.js, add a line like this:

     ```javascript
     # will display "Select new field..." in textbox
     {input: 'newfield',      sTitle: 'new field', bFilterable: true}, 
     ```

  4. Add the autocomplete widget along the side in html/iframe/iframe.html. If the id of the select
     tag is "filtered_<fieldname>", then the Datatable init code will automatically create it.
    
     ```html
     <select id="filtered_newfield" multiple="multiple" ></select>
     ```

* Q. How do I make a custom filter (not a Select2 dropdown)?

  A. You'll still need to add it to the scraper and the datatable definition. The main question
     then is how to do the control.

     You want to create your custom control in iframe/iframe.html, and then write two functions
     that work together:

     * a custom onChange event handler for your widget
     * a custom filter function for DataTable


     See fnFilterGradesServed and onSliderChange for an example of how I did this with the
     grades served slider.


* Q. How do I change the display of each school's information?

  A. The actual school rows are rendered as a single cell of a data table. The rendering function
     is fnCreatedRow in html/js/datatable.js.

Deploy
===============

```
[remote "production"]
	url = git@heroku.com:disruptedstudent.git
	fetch = +refs/heads/*:refs/remotes/production/*
[remote "staging"]
	url = git@heroku.com:disruptedstudent-staging.git
	fetch = +refs/heads/*:refs/remotes/heroku/*
```

Preview staging embedded at http://www.innosightinstitute.org/media-room/publications/blended-learning/database-staging/
Preview localhost:5000 embedded at http://www.innosightinstitute.org/media-room/publications/blended-learning/database-local/
