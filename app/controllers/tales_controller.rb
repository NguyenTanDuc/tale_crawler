class TalesController < ApplicationController
  before_action :setup_mechanize, only: :index

  def index
    links = []
    titles = []
    authors = []
    categories = []
    status = []

    home_page = @agent.get(Settings.url.base_url)
    links = get_element(home_page, "div#content ul.content li > a:nth-child(2)", 3)

    links.each do |link|
      page_detail = @agent.get(link)
      titles << get_element(page_detail, "div.title h1")
      authors << get_element(page_detail, "div.author:nth-child(1) a")
      categories << get_element(page_detail, "div.author:nth-child(2) a")
      if get_element(page_detail, "div.author:nth-child(3) a") == "FULL"
        status << 1
      else
        status << 0
      end
    end
  end

  # type = 1: get text
  # type = 2: get html
  # type = 3: get href
  def get_element page, html_element, type = 1
    case type
    when 1
      page.search(html_element).text
    when 2
      page.search(html_element).to_html
    when 3
      page.search(html_element).map{|link| link["href"]}
    else
      page.search(html_element).text
    end
  end

  private
  def setup_mechanize
    @agent = Mechanize.new
    @agent.user_agent_alias = 'Mac Safari'
  end
end
