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
      result = {
          'url' => link['href'],
          'source' => 'innosight'
          }
      
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
    node = doc.xpath('//td[.="' + field + '"]/following-sibling::td[1]').pop
    return node ? node.text.strip : nil 
  end
end

# Port of the original perl scraping script
# As we add additional data sources, they should become their own classes
class EdSurgeScraper
  @@list_url= 'https://www.edsurge.com/s'

  @results = []

  def initialize
    doc = Nokogiri::HTML(open(@@list_url))
    links = doc.css('div#index_show_objects > div.object_partial > a')
    puts "Found " + links.count.to_s + " schools\n"

    @results = []
    
    links.each {|link|
      uri = URI.parse(@@list_url).merge(link['href']).to_s
      doc = Nokogiri::HTML(open(uri))
      result = {
          'url' => uri,
          'source' => 'edsurge'
          }
      
      # css scraping
      result['title']     = scrape(doc, 'div#md_n')
      result['detail']    = scrape(doc, 'div#md_d')
      
      # arrays
      result['desc']    = doc.search('div#basics_section > div > div > p')
      result['products']    = doc.search('div#products * a')


      puts " Processed " + result['title'] + "\n"
      @results.push(result)
      break
    }
  end

  def results
    @results
  end
  
  def scrape(doc, search)
    node = doc.search(search).pop
    return node ? node.text.strip : nil 
  end
end


# first: scrape

innosight = InnosightScraper.new
#edsurge = EdSurgeScraper.new

# this should be using the CLOUDANT_URL env variable, but i'm not sure how to get that on my local machine
@db = CouchRest.database!("https://app4701148.heroku:oueLS2tF0oJjCCvIOk6xaHDi@app4701148.heroku.cloudant.com/example")
@db.delete!
@db.create!
@db.bulk_save(innosight.results)
#@db.bulk_save(edsurge.results)
