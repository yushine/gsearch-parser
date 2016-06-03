require 'open-uri'
require 'nokogiri'
require 'uri'

#
# Module method definitions
#
module GSearchParser

  # Entry method for performing a web search
  def GSearchParser.webSearch(query)
    GoogleWebSearch.new(query, 'QUERY')
  end

  # Allows directly specifing the URI of the page to parse
  def GSearchParser.parseSearchPage(uri)
    GoogleWebSearch.new(uri, 'URI')
  end

end

#
# Google Web Search class
#
class GoogleWebSearch
  attr_accessor :results, :nextURI
  @currentPage
  
  # Class initializer
  def initialize(arg1, flag)
    # Initialize variables
    @results = Array.new

    case flag
      when 'QUERY'
        # Format query
        query = arg1.gsub(/ /, '+')
        updateResults("https://google.com/search?#{URI.encode_www_form(q: query)}")
      when 'URI'
        updateResults(arg1)
    end

    # Update next URI
    updateNextURI
  end

  # Update the nextURI attribute
  def updateNextURI
    # Parse next result page link from the currently marked one
    nextPagePath = @currentPage.at_css('table#nav tr td.cur').next_sibling().at_css("a")['href']

    # Construct the URI
    @nextURI = 'https://www.google.com' + nextPagePath
  end

  # Update the WebSearch results array by performing a Fetch, Store, Parse routine
  def updateResults(url)
    # Fetch
    searchPage = fetchPage(url)

    # Store
    @currentPage = searchPage

    # Parse
    parseCurrentPage
  end

  # Fetch the page from a URL
  def fetchPage(url)
    Nokogiri::HTML(open(url, 'User-Agent' => 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.152 Safari/535.19').read, nil, 'utf-8')
  end

  # Parse the current page and populate results
  def parseCurrentPage
    # Initialize local variables
    currentResults = Array.new

    # Iterate over each Google result list element 
    @currentPage.css('li.g:not([id])').each do |result|
      begin
        # Extract the title
        title = result.css('h3 a').first.content

        # Extract the content. There is the possibility for
        # the content to be nil, so check for this
        content = result.css('span.st').first.nil? ? '' : result.css('span.st').first.content

        # Extract the URI
        uri = result.css('h3 a').first['href']

        # Ignore YouTube videos for websearch
        unless uri.index('www.youtube.com').nil?
          next
        end

        # Create a new Result object and append to the array
        currentResults << Result.new(title, content, uri)
      rescue NoMethodError
        next
      end
    end
    @results += currentResults
    return currentResults
  end

  # Parse the results from the next page and append to results list
  def nextResults
    # Update results
    updateResults(@nextURI)

    # Update nextURI
    updateNextURI
  end

  # Iterator over results
  def each(&blk)
    @results.each(&blk)
  end

end # GoogleWebSearch

#
# Result class
#
class Result
  attr_accessor :title, :content, :uri

  # Class initializer
  def initialize(title, content, uri)
    @title = title
    @content = content
    @uri = uri
  end

end # Result

