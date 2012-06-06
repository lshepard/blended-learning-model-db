require 'rubygems'
require 'bundler/setup'
require 'couchrest'
require 'nokogiri'
require 'open-uri'
require 'pp'

# Port of the original perl scraping script
# As we add additional data sources, they should become their own classes
class InnosightScraper
  @@list_url= 'http://www.innosightinstitute.org/media-room/publications/blended-learning/' +
    'blended-learning-profiles-all-profiles/'

  @results = []

  def initialize
    doc = Nokogiri::HTML(open(@@list_url))
    links = doc.css('div.entry > div > strong > p >a')
    puts "Found " + links.count.to_s + " blended learning profiles\n"

    @results = []
    
    links.each {|link| 
      doc = Nokogiri::HTML(open(link['href']))
      result = {'url' => link['href']}
      
      # css scraping
      result['title']     = scrape(doc, 'div.post > h2')
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
      
      # table scraping
      result['type']      = scrape_row(doc, 'Operator type')
      result['focus']     = scrape_row(doc, 'Focus')
      result['gradesserved']     = scrape_row(doc, 'Grades served')
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
      result['lmssislink'] = scrape_row(doc, 'Link between LMS and SIS')
      result['othertools'] = scrape_row(doc, 'Other tools')
      
      puts " Processed " + result['title'] + "\n"
      @results.push(result)
    }
  end

  def results
    @results
  end
  
  def scrape(doc, search)
    node = doc.search(search).pop
    return node ? node.text.strip : nil 
  end
  
  def scrape_row(doc, field)
    node = doc.xpath('//td[.="' + field + '"]/following-sibling::td[1]')
    return node ? node.text.strip : nil 
  end
end


# first: scrape

r = InnosightScraper.new

# this should be using the CLOUDANT_URL env variable, but i'm not sure how to get that on my local machine
@db = CouchRest.database!("https://app4701148.heroku:oueLS2tF0oJjCCvIOk6xaHDi@app4701148.heroku.cloudant.com/example")
@db.delete!
@db.create!
@db.bulk_save(r.results)