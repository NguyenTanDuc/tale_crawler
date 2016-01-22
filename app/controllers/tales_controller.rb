class TalesController < ApplicationController
  before_action :setup_mechanize, only: :index

  TYPE_TEXT = 1
  TYPE_HTML = 2
  TYPE_HREF = 3

  def index
    chapter_links = Array.new
    names = Array.new
    authors = Array.new
    status = Array.new
    categories = Array.new

    home_page = @agent.get(Settings.url.base_url)
    links = get_element(home_page, "div#content ul.content li > a:nth-child(2)", TYPE_HREF)
    # all_tale_links = get_all_links(home_page, "div#content ul.content li > a:nth-child(2)", "div.bt_pagination .next > a")
    # all_tale_links.each do |tale_link|
    #   TaleLink.create! tale_link: tale_link
    # end

    TaleLink.pluck(:tale_link).each do |tale_link|
      tale_page = @agent.get(tale_link)

      tale_name = get_element(tale_page, "div.title h1", TYPE_TEXT)
      author_name = get_element(tale_page, "div.author:nth-child(1) > a", TYPE_TEXT)
      category_name = get_element(tale_page, "div.author:nth-child(2) > a", TYPE_TEXT)
      status = (get_element(tale_page, "div.author:nth-child(3) > a", TYPE_TEXT) == "FULL")

      if category_name.present?
        category = Category.new name: category_name
        category.save
      end

      if author_name.present?
        author = Author.new name: author_name
        author.save
      end

      tale = Tale.new(name: tale_name, author: author, status: status,
              category_id: Category.find_by(name: category_name).id, source: Settings.url.base_url,
              link: tale_link)
      binding.pry

      chapter_links = get_all_links(tale_page, "div.danh_sach > a", "div.bt_pagination .next > a")
      break
    end
    chapter_links.shift(5) if chapter_links.count > 5
    puts "abc"
  end



  def get_all_links page, link_element, next_page_element, store_array = []
    store_array << get_element(page, link_element, TYPE_HREF)
    puts store_array
    next_page = get_next_page(page, next_page_element)
    if next_page.nil?
      return store_array.flatten.uniq
    else
      get_all_links(next_page, link_element, next_page_element, store_array)
    end
  end

  def get_next_page page, next_page_element
    if page.at_css(next_page_element).present?
      next_link = get_element(page, next_page_element, TYPE_HREF)
      next_page = @agent.get(next_link.first)
      next_page
    else
      nil
    end
  end

  # def get_content links
  #   links_chapter = []

  #   tales_link = links.first
  #   page_detail = @agent.get(link)

  #   links_chapter <<
  # end

  def next_page
  end

  # type = 1: get text
  # type = 2: get html
  # type = 3: get href
  def get_element page, html_element, type = TYPE_TEXT
    return nil if page.at_css(html_element).nil?

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
