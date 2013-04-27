require 'rubygems'
require 'bundler/setup'
require 'couchrest'
require 'nokogiri'
require 'open-uri'
require 'pp'
require 'date'
require 'logger'

# Port of the original perl scraping script
# As we add additional data sources, they should become their own classes
class InnosightScraper
  @results = {}

  def initialize(output = STDOUT)
    @logger = Logger.new(output)

    urls = scrape_profile_urls_from_custom_listing_page
    @logger.info "Found #{urls.count} blended learning profiles\n"

    @logger.info "Reading profile pages..."


    @results = {}

    # Fetch and parse docs in parallel
    docs = {}
    threads = []
    urls.each do |url|
      begin
        threads << Thread.new do
          docs[url] = read_and_parse(url)
        end
      rescue Exception => e
        @logger.info "Issue reading #{url} " + e.to_s + "\n"
        raise e
      end
    end
    threads.each(&:join)

    # Parse serially (since some overwrite others, and this is fast enough anyway)
    docs.each do |url, doc|
      scrape_doc(url, doc)
    end
  end

  def upload
    if results
      @logger.info "Finished collecting results"
      @logger.info "Storing them into the database"
      # this should be using the CLOUDANT_URL env variable
      # @db = CouchRest.database!("http://localhost:5984/bluscrapes")
      @db = CouchRest.database!("https://app4701148.heroku:oueLS2tF0oJjCCvIOk6xaHDi@app4701148.heroku.cloudant.com/cci-scrape")
      @logger.info "Recreating db"
      @db.delete! rescue nil
      @db.create!
      @logger.info "Saving #{results.size} results"
      @db.bulk_save(results)
      @logger.info "Done"
    end
  end

  def results
    @results.values
  end

  private

  def scrape_profile_urls_from_custom_listing_page(listing_url = 'http://wpdev.designfarm.com/cci/?page_id=11800')
    doc = read_and_parse(listing_url)
    urls = doc.search('#content a').map { |a| a['href'] }
  end

  def scrape_doc(url, doc)
    result = {}

    result['url']      = url
    result['source']   = 'innosight'
    result['title']    = scrape(doc, 'div#main h1')
    result['detail']   = nil # this was not populated with anything intentional anymore JM 28-Mar-2013
    result['postdate'] = nil # this is gone on the wp pages, was there on wp posts

    if (/(.*), (.*)$/.match(scrape_row(doc, 'Headquarters')))
      result['hqcity']  = $1
      result['hqstate'] = drop_trailing_parenthetical($2)
    end

    # custom free text scraping
    result['programmodels']    = scrape(doc, '//div/p[strong[contains(.,"Program model:")]]/text()')
    result['modeldescription'] = scrape(doc, '//div/p[strong[contains(.,"Model description")]]/text()')

    # table scraping
    result['type']             = scrape_row(doc, 'Type')
    result['focus']            = scrape_row(doc, 'Focus')
    result['gradesserved']     = scrape_row(doc, 'Grades served')
    result['firstyear']        = scrape_row(doc, 'First year of operation')
    result['frl']              = drop_trailing_parenthetical(scrape_row(doc, '% FRL'))
    result['minority']         = drop_trailing_parenthetical(scrape_row(doc, '% Black or Hispanic'))
    result['revenueperpupil']  = scrape_row(doc, 'Revenue per pupil')
    result['blendedgrades']    = scrape_row(doc, 'Blended grades')
    result['blendedenrollment']= scrape_row(doc, 'Enrollment')
    result['blendedsubjects']  = scrape_row(doc, 'Blended subjects')
    result['content']          = scrape_row(doc, 'Content')
    result['sis']              = scrape_row(doc, 'SIS')
    result['indylms']          = scrape_row(doc, 'Independent LMS')
    result['indygradebook']    = scrape_row(doc, 'Independent gradebook')
    result['indyassessment']   = scrape_row(doc, 'Independent assessment')
    result['profdevel']        = scrape_row(doc, 'Professional development')
    result['othertools']       = scrape_row(doc, 'Other tools')
    result['renamedto']        = scrape_row(doc, 'Now profiled as')

    # When Innosight updates a profile, they will actually create a new profile
    # with the same name as the old one. We dedupe based on the listing - last
    # one wins
    if @results[result['title']]
      @logger.info " -- overwriting previous " + result['title']
    end

    @logger.info " Processed " + result['title'] + "\n"
    @results[title] = result
  end


  def scrape(doc, search)
    node = doc.search(search).pop
    return node ? node.text.strip : nil 
  end

  def scrape_row(doc, field)
    node = doc.xpath('//td[.="' + field + '"]/following-sibling::td[1]').pop
    return node ? node.text.strip : nil 
  end

  def drop_trailing_parenthetical(string)
    if string.nil?
      nil
    else
      string.sub(/ \(.*\)$/, '')
    end
  end

  def read_and_parse(url, tries = 5)
    try = 1
    begin
      html = open(url).read
      if ENV['SAVE_HTML_FOR_DEBUGGING']
        filename = url.gsub(/[:\/]/, '-')
        File.open("tmp/#{filename}", "w") { |f| f.puts html }
      end
      doc = Nokogiri::HTML(html)
      @logger.info "Read and parsed #{url}"
      doc
    rescue Exception => e
      @logger.info "Encountered exception on try #{try} for to read #{url}:"
      @logger.info "#{e.class}: #{e.message}"
      @logger.info e.backtrace
      @logger.info
      try += 1
      retry if try < tries
    end
  end

end
