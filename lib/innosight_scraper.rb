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

    urls = scrape_profile_urls_from_listing_pages
    @logger.info "Found #{urls.count} blended learning profiles\n"

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
      @logger.info "Finished collection results; storing them into the database"
      # this should be using the CLOUDANT_URL env variable, but i'm not sure how to get that on my local machine
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

  def scrape_profile_urls_from_listing_pages
    urls = []
    threads = []

    listing_page_urls.map { |url|
      threads << Thread.new do
        doc = read_and_parse(url)
        links = doc.search('h2.entry-title a')
        urls << links.map { |a| a['href'] }
      end
    }

    threads.each(&:join)

    urls.flatten
  end

  def listing_page_urls
    # TODO either intelligently enumerate pages or find a grand listing page like the old one:
    # @@list_url= 'http://www.innosightinstitute.org/media-room/publications/blended-learning/blended-learning-profiles-all-profiles/'
    [
      # innosight's profiles
      'http://wpdev.designfarm.com/cci/?cat=41&paged=1',
      'http://wpdev.designfarm.com/cci/?cat=41&paged=2',
      'http://wpdev.designfarm.com/cci/?cat=41&paged=3',
      'http://wpdev.designfarm.com/cci/?cat=41&paged=4',
      'http://wpdev.designfarm.com/cci/?cat=41&paged=5',

      # reader-generated profiles
      'http://wpdev.designfarm.com/cci/?cat=23&paged=1',
      'http://wpdev.designfarm.com/cci/?cat=23&paged=2',
      'http://wpdev.designfarm.com/cci/?cat=23&paged=3',
      'http://wpdev.designfarm.com/cci/?cat=23&paged=4'
    ]
  end

  def scrape_doc(url, doc)

    result = {}

    result['url']      = url
    result['source']   = 'innosight'
    result['title']    = scrape(doc, 'div.post > h2') || scrape(doc, 'div.post > a.sh2')
    result['detail']   = nil # this was not populated with anything intentional anymore JM 28-Mar-2013
    result['postdate'] = scrape(doc, 'div.post > em.date')

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
    # with the same name as the old one. We dedupe based on the post date - most recent
    # one wins
    title = result['title']
    if @results[title]
      if (Date.parse(@results[title]['postdate']) > Date.parse(result['postdate']))
        @logger.info "  -- rejected " + result['title']
        return
      else
        @logger.info " -- overwrote previous " + result['title']
      end
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
