require_relative '../lib/gsearch-parser'
require 'test/unit'
require 'uri'
# require 'pry'
# require 'plymouth'

class TestFetch < Test::Unit::TestCase
  def test_google
    search = GSearchParser.webSearch 'google'
    assert search.results.length >= 5
    search.each do |result|
      URI(result.uri).path
    end
  end

  def test_chinese
    search = GSearchParser.webSearch '看见'
    assert search.results.length >= 5
    search.each do |result|
      URI(result.uri)
    end
  end
end