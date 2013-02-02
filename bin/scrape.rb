require 'rubygems'
require 'bundler/setup'
require 'couchrest'
require 'nokogiri'
require 'open-uri'
require 'pp'
require 'date'

# Port of the original perl scraping script
# As we add additional data sources, they should become their own classes
class InnosightScraper
  @@list_url= 'http://www.innosightinstitute.org/media-room/publications/blended-learning/' +
    'blended-learning-profiles-all-profiles/'

  @results = {}

  def initialize
    doc = Nokogiri::HTML(open(@@list_url))
    links = doc.css('div.entry > div > strong > p > a')
    puts "Found " + links.count.to_s + " blended learning profiles\n"

    @results = {}

    links.each {|link|
      begin
        scrape_link(link)
      rescue Exception => e
        puts "Issue with #{link['href']} " + e.to_s + "\n"
        raise e
      end
    }
  end

  def read_and_parse(url, tries = 5)
    try = 1
    begin
      html = open(url).read
      unless ENV['DO_NOT_CACHE_HTML']
        filename = url.gsub(/[:\/]/, '-')
        File.open("tmp/#{filename}", "w") { |f| f.puts html }
      end
      puts url
      doc = Nokogiri::HTML(html)
    rescue Exception => e
      puts "Encountered exception on try #{try} for to read #{url}:"
      puts "#{e.class}: #{e.message}"
      puts e.backtrace
      puts
      try += 1
      retry if try < tries
    end
  end

  def scrape_link(link)
    doc = read_and_parse(link['href'])

    result = {
      'url' => link['href'],
      'source' => 'innosight'
    }

    # css scraping
    title = result['title']     = scrape(doc, 'div.post > h2') || scrape(doc, 'div.post > a.sh2')
    result['detail']    = scrape(doc, 'div.post > div.entry > p > span')

    # regexes for postdate and splitting out hq
    if (/Posted on (\S+ \d+)\S*(, \d+) by/.match(scrape(doc, 'div.post > div.postdate')))
      result['postdate'] = $1 + $2
    end

    if (/(.*), (.*)$/.match(scrape_row(doc, 'Headquarters')))
      result['hqcity'] = $1
      result['hqstate'] = $2
    end

    # custom free text scraping
    result['programmodels'] = scrape(doc, '//div/p[strong[contains(.,"Program model:")]]/text()')
    result['modeldescription'] = scrape(doc, '//div/p[strong[contains(.,"Model description")]]/text()')

    # table scraping
    result['type']      = scrape_row(doc, 'Type')
    result['focus']     = scrape_row(doc, 'Focus')
    result['gradesserved']     = scrape_row(doc, 'Grades served')
    result['firstyear']     = scrape_row(doc, 'First year of operation')
    result['frl']     = scrape_row(doc, '% FRL')
    result['minority']     = scrape_row(doc, '% Black or Hispanic')
    result['revenueperpupil']     = scrape_row(doc, 'Revenue per pupil')
    result['blendedgrades']     = scrape_row(doc, 'Blended grades')
    result['blendedenrollment']     = scrape_row(doc, 'Enrollment')
    result['blendedsubjects']     = scrape_row(doc, 'Blended subjects')
    result['content']     = scrape_row(doc, 'Content')
    result['sis']     = scrape_row(doc, 'SIS')
    result['indylms']     = scrape_row(doc, 'Independent LMS')
    result['indygradebook'] = scrape_row(doc, 'Independent gradebook')
    result['indyassessment'] = scrape_row(doc, 'Independent assessment tool')
    result['profdevel'] = scrape_row(doc, 'Professional development')
    result['othertools'] = scrape_row(doc, 'Other tools')


    # When Innosight updates a profile, they will actually create a new profile
    # with the same name as the old one. We dedupe based on the post date - most recent
    # one wins
    if @results[title]
      if (Date.parse(@results[title]['postdate']) > Date.parse(result['postdate']))
        puts "  -- rejected " + result['title'] + "\n"
        return
      else
        puts " -- overwrote previous " + result['title'] + "\n"
      end
    end

    puts " Processed " + result['title'] + "\n"
    @results[result['title']] = result
  end

  def results
    @results.values
  end

  def scrape(doc, search)
    node = doc.search(search).pop
    return node ? node.text.strip : nil 
  end

  def scrape_row(doc, field)
    node = doc.xpath('//td[.="' + field + '"]/following-sibling::td[1]').pop
    return node ? node.text.strip : nil 
  end
end

innosight = InnosightScraper.new

if (innosight.results)
  # this should be using the CLOUDANT_URL env variable, but i'm not sure how to get that on my local machine
  @db = CouchRest.database!("https://app4701148.heroku:oueLS2tF0oJjCCvIOk6xaHDi@app4701148.heroku.cloudant.com/example")
  @db.delete!
  @db.create!
  @db.bulk_save(innosight.results)
end
