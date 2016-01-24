module TalesHelper
  TYPE_TEXT = 1
  TYPE_HTML = 2
  TYPE_HREF = 3

  def convert_content content_html, type = nil
    content_html.gsub!(/<td.*\/div>|<\/td>/, "")
    content_text = content_html.gsub(/<p.*?>/x, "")
    content_text = content_text.gsub!(/<\/p>|<\/?br>/, "\n")
    content_text.strip!
    return content_html, content_text
  end

  def convert_title chap_title, type = nil
    chap_title = chap_title.try(:split, ":")
    if chap_title.size > 2
      merge_title = chap_title[1..-1].join(" ")
      chap_title.pop(chap_title.size - 1)
      chap_title << merge_title
    end
    chap_array = /(\d+)+/.match(chap_title[0]).to_a
    chap_title[0] = chap_array[1]
    chap_title
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
    tries = 0
    begin
      if page.at_css(next_page_element).present?
        next_link = get_element(page, next_page_element, TYPE_HREF)
        next_page = @agent.get(next_link.first)
        next_page
      else
        nil
      end
    rescue => e
      tries += 1
      current_time = Time.now
      File.open("crawlerlog.txt", "a+") do |file|
        file << "#{e} in url #{current_time}\n-----------------------\n"
      end
      retry if tries < 10
    end
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
end
