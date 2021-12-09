#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Member
    def name
      noko.css('b').text.tidy
    end

    def position
      # Split senior ministers into two positions
      raw_position.sub('Menteri Kanan','Menteri Kanan|Menteri Kanan').split('|')
    end

    private

    def raw_position
      noko.xpath('.//text()').map(&:text).select { |txt| txt.include? 'Menteri' }.first.tidy.delete_suffix(',')
    end
  end

  class Members
    def member_container
      noko.css('.box')
    end
  end
end

file = Pathname.new 'html/official.html'
puts EveryPoliticianScraper::FileData.new(file).csv
