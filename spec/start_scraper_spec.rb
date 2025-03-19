require 'rspec'
require_relative '../google_scraper.rb'

RSpec.describe 'GoogleScraper Script' do
  let(:scraper_instance) { instance_double(GoogleScraper) }

  before do
    allow(GoogleScraper).to receive(:new).and_return(scraper_instance)
    allow(scraper_instance).to receive(:perform)
  end

  context 'when query argument is provided' do
    it 'creates a GoogleScraper instance and calls perform' do
      stub_const('ARGV', ['query=hello'])

      # Reload script logic
      load './start_scraper.rb'

      expect(GoogleScraper).to have_received(:new).with('hello')
      expect(scraper_instance).to have_received(:perform)
    end
  end

  context 'when query argument is missing' do
    it 'raises an error' do
      stub_const('ARGV', [])

      expect { load './start_scraper.rb' }.to raise_error(RuntimeError, 'Must have query args')
    end
  end
end
