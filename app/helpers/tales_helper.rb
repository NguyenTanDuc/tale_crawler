module TalesHelper
  TYPE_TEXT = 1
  TYPE_HTML = 2
  TYPE_HREF = 3

  LOG_ERROR  = 1
  LOG_WORKER = 2

  def get_element page, html_element, type = TYPE_TEXT
    return "" if page.at_css(html_element).nil?

    case type
    when 1
      page.search(html_element).text.try(:squish)
    when 2
      page.search(html_element).inner_html.try(:squish)
    when 3
      page.search(html_element).map{|link| link["href"]}
    else
      page.search(html_element).text.try(:squish)
    end
  end

  def log_message message, type_log, link = nil
    current_time = Time.now
    file_name = if type_log == LOG_WORKER
                  Settings.logger.file_name_worker
                else
                  Settings.logger.file_name_error
                end
    File.open(file_name, "a+") do |file|
      file << "#{message} at #{current_time} - link: #{link}\n-----------------------\n"
    end
    sleep(5)
  end

  def convert_content content_html, type = nil
    begin
      if type == 1
        content_array = content_html.scan(/http[\w:\/\/.]+/)
        content_array.pop if content_array.size > 1
        content_html = content_array.try(:join, ", ")
        content_text = content_html
      else
        content_html.gsub!(/<div.*\/div>/, "")
        content_text = content_html.gsub(/<p.*?>/x, "")
        content_text = content_text.gsub!(/<\/p>|<\/?br>/, "\n")
        content_text.try(:strip!)
      end
    rescue
      content_html = ""
      content_text = ""
    end
    return content_html, content_text
  end

  def convert_title chap_title, type = nil
    return ["", ""] if chap_title.blank?
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
    next_page = get_next_page(page, next_page_element)
    if next_page.nil?
      puts store_array
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
      log_message(e.message, LOG_ERROR)
      retry if tries < 10
    end
  end
end
