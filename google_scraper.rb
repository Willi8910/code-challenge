require 'selenium-webdriver'
require 'byebug'
require 'securerandom'
require 'fileutils'
require 'json'
require 'optparse'

class GoogleScraper
  GOOGLE_HOST = 'https://www.google.com'

  attr_reader :query, :driver, :directory_name

  def initialize(query)
    @query = query
    @directory_name = "results/#{query.gsub(/\W/, '')}_results"

    # Setup Selenium WebDriver (Chrome)
    # setup in way to avoid detection by google
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--disable-blink-features=AutomationControlled')
    options.add_argument('--disable-infobars')
    options.add_argument('--start-maximized')
    options.add_argument('--disable-gpu')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')

    # Set a real User-Agent
    user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36"
    options.add_argument("--user-agent=#{user_agent}")
    # options.add_argument('--headless') # Run Chrome in headless mode
    @driver = Selenium::WebDriver.for :chrome, options: options
  end

  def perform
    begin
      # Open the target webpage
      driver.navigate.to "#{GOOGLE_HOST}/search?q=#{query}"
      random_sleep

      # Wait until the page is fully loaded
      wait = Selenium::WebDriver::Wait.new(timeout: 10) # Adjust timeout as needed
      wait.until { driver.execute_script('return document.readyState') == 'complete' }

      # Take a screenshot and save it
      FileUtils.mkdir_p directory_name
      screenshot_path = "#{directory_name}/screenshot.png"
      driver.save_screenshot(screenshot_path)

      page_html = driver.page_source
      File.open("#{directory_name}/page_source.html", 'w') { |file| file.write(page_html) }

      result = {}
      result.merge!(scrape_artwork)
      result.merge!(scrape_images)
      json_result = JSON.pretty_generate(result)
      File.open("#{directory_name}/expected_array.json", "w") do |file|
        file.write(json_result)
      end
    ensure
      driver.quit # Ensure the browser is closed
    end
  end

  private

    def scrape_artwork
      artwork_box_classname = 'Cz5hV'
      artwork_boxes = driver.find_elements(:class, artwork_box_classname)
      return {} unless artwork_boxes.any?

      artwork_box = artwork_boxes.first
      items = artwork_box.find_elements(:tag_name, 'a')
      item_result = items.map do |item|
        link = item.attribute('href')

        image_element = item.find_element(:tag_name, 'img')
        image = image_element.attribute('src')

        name_class_name = 'pgNMRc'
        name = item.find_element(:class, name_class_name).text

        extentions_class_name = 'cxzHyb'
        extentions = item.find_element(:class, extentions_class_name).text
        extentions = extentions.split(' · ')
        {
          name: name,
          extentions: extentions,
          link: link,
          image: image
        }
      end

      {
        artwork: item_result
      }
    end

    def scrape_images
      image_box_classname = 'iur'
      image_boxes = driver.find_elements(:id, image_box_classname)
      return {} unless image_boxes.any?

      driver.find_element(:class_name, 'jEgXc').click

      image_box = image_boxes.first
      items = image_box.find_elements(:class_name, 'w43QB')
      item_result = items.map do |item|
        link_element = item.find_element(:tag_name, 'a')
        link = link_element.attribute('href')

        image_element = item.find_element(:class_name, 'gdOPf').find_element(:tag_name, 'img')
        image = image_element.attribute('src')

        source_box = item.find_element(:class_name, 'VaiWld')

        title_class_name = 'Yt787'
        title = item.find_element(:class_name, title_class_name).text

        source_icon_element = source_box.find_element(:tag_name, 'img')
        source_icon = source_icon_element.attribute('src')

        source_site_class_name = 'R8BTeb'
        source_site = item.find_element(:class_name, source_site_class_name).text

        {
          title: title,
          source_icon: source_icon,
          source_site: source_site,
          link: link,
          image: image
        }
      end

      {
        image: item_result
      }
    end

    def random_sleep
      sleep rand(1..2)
    end
end
