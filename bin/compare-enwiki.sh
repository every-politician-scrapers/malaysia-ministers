#!/bin/bash

bundle exec ruby bin/scraper/wikipedia.rb | ifne tee data/wikipedia.csv
wd sparql -f csv bin/scraper/wikidata-enwiki.js | sed -e 's/T00:00:00Z//g' | qsv dedup -s psid | ifne tee data/wikidata-enwiki.csv
bundle exec ruby bin/wikipedia-diff.rb | tee data/wikipedia-diff.csv
