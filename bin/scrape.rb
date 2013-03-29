#!/usr/bin/env ruby

require_relative '../lib/innosight_scraper'

if $0 == __FILE__
  InnosightScraper.new(STDOUT).upload
end
