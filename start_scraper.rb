require_relative 'google_scraper'

args = ARGV.map { |arg| arg.split('=', 2) }.to_h
query = args['query']
raise("Must have query args") if query.nil?

scraper = GoogleScraper.new(query)
scraper.perform
