require 'rspec'
require 'json'
require_relative '../google_scraper.rb'

describe 'Google Image Scraper' do
  let(:query) { 'Johannes Vermeer artwork'}

  describe '#scrape' do
    it 'returns correct result' do
      GoogleScraper.new(query).perform
      expected_directory = './results/JohannesVermeerartwork_results'

      # check if file generated
      expect(Dir.exist?(expected_directory)).to be_truthy
      expect(File.exist?("#{expected_directory}/expected_array.json")).to be_truthy
      expect(File.exist?("#{expected_directory}/page_source.html")).to be_truthy
      expect(File.exist?("#{expected_directory}/screenshot.png")).to be_truthy

      # test first item
      file_content = File.read("#{expected_directory}/expected_array.json")
      data = JSON.parse(file_content)
      item = data['artwork'][0]
      expect(item["name"]).to eq("Gadis dengan Anting-Anting Mutiara")
      expect(item["extentions"]).to eq(["1665"])
      expect(item['link']).not_to be_nil
      expect(item['image']).not_to be_nil

      FileUtils.rm_rf(expected_directory)
    end
  end
end
