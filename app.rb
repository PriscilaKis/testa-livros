require 'rubygems'
require 'bundler/setup'
require 'selenium-webdriver'
require 'minitest/autorun'
require 'minitest/reporters'

Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(color: true)]

def get_book_info_on_submarino
  @driver.get('https://www.submarino.com.br/categoria/livros')
  @driver.find_element(css: '.item-list a').click

  book_author = @driver.find_element(xpath: '//a[contains(@class, "author")]//span').text
  book_isbn = @driver.find_element(xpath: '//td//span[contains(text(), "ISBN")]/../../td[2]').text

  {
    author: book_author,
    isbn: book_isbn
  }
end

def find_book_on_americanas(isbn)
  @driver.navigate.to('https://www.americanas.com.br')
  search_input = @driver.find_element(id: 'h_search-input')
  search_input.send_keys(isbn)
  search_input.submit
  product_found = @driver.find_element(css: '.product-grid a:first-child')
  product_found.click

  book_author = @driver.find_element(xpath: '//td//span[contains(text(),"Autor")]/../../td[2]').text

  { author: book_author }
end

def find_book_on_shoptime(isbn)
  @driver.navigate.to('https://www.shoptime.com.br')
  search_input = @driver.find_element(id: 'h_search-input')
  search_input.send_keys(isbn)
  search_input.submit
  product_found = @driver.find_element(css: '.product-grid a:first-child')
  product_found.click

  book_author = @driver.find_element(xpath: '//td//span[contains(text(),"Autor")]/../../td[2]').text

  { author: book_author }
end

describe 'Books' do
  before do
    caps = Selenium::WebDriver::Remote::Capabilities.chrome(
      'goog:chromeOptions' => { 'args' => ['--start-maximized'] } )
    @driver = Selenium::WebDriver.for(:chrome, desired_capabilities: caps)
    @driver.manage.timeouts.implicit_wait = 10
  end

  after do
    @driver.quit
  end

  describe 'book author name validation' do
    it 'must have the same author from submarino in americanas and shoptime websites' do
      submarino_book = get_book_info_on_submarino

      americanas_book = find_book_on_americanas(submarino_book[:isbn])

      shoptime_book = find_book_on_shoptime(submarino_book[:isbn])

      assert_equal(submarino_book[:author], americanas_book[:author])
      assert_equal(submarino_book[:author], shoptime_book[:author])
    end
  end
end
