#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  def header_column
    'Portrait'
  end

  # TODO: make this easier to override
  def holder_entries
    noko.xpath("//table[.//th[contains(.,'#{header_column}')]][1]//tr[td]")
  end

  class Officeholder < OfficeholderBase
    def columns
      %w[color picture name party title start end].freeze
    end

    def tds
      noko.css('td,th')
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
