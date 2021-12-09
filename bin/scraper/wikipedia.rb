#!/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'pry'
require 'scraped'
require 'table_unspanner'
require 'wikidata_ids_decorator'

require 'open-uri/cached'

class RemoveReferences < Scraped::Response::Decorator
  def body
    Nokogiri::HTML(super).tap do |doc|
      doc.css('sup.reference').remove
    end.to_s
  end
end

class UnspanAllTables < Scraped::Response::Decorator
  def body
    Nokogiri::HTML(super).tap do |doc|
      doc.css('table.wikitable').each do |table|
        unspanned_table = TableUnspanner::UnspannedTable.new(table)
        table.children = unspanned_table.nokogiri_node.children
      end
    end.to_s
  end
end

class MinistersList < Scraped::HTML
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  field :ministers do
    member_entries.map { |ul| fragment(ul => Officeholder).to_h }
  end

  private

  def member_entries
    noko.xpath('//table[.//th[contains(.,"Portfolio")]][1]//tr[td]')
  end
end

class Officeholder < Scraped::HTML
  field :wdid do
    person_link.attr('wikidata')
  end

  field :name do
    person_link.text.tidy
  end

  field :pid do
    tds[0].css('a/@wikidata')
  end

  field :position do
    tds[0].text.tidy
  end

  private

  def tds
    noko.css('td')
  end

  def person_link
    tds[1].css('a').first
  end
end

url = 'https://en.wikipedia.org/wiki/Ismail_Sabri_cabinet'
data = MinistersList.new(response: Scraped::Request.new(url: url).response).ministers

header = data.first.keys.to_csv
rows = data.map { |row| row.values.to_csv }
abort 'No results' if rows.count.zero?

puts header + rows.join
