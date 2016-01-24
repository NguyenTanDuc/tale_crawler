class TaleCrawlerWorker
  include Sidekiq::Worker
  include TalesHelper

  def perform class_num
    @agent = Mechanize.new
    @agent.user_agent_alias = 'Mac Safari'
    @class_num = class_num
    chapter_links = Array.new
    all_tale = TaleLink.count
    step = (all_tale.to_f / Settings.worker.number).ceil
    start_index = (class_num - 1)

    TaleLink.offset(start_index).limit(step).pluck(:tale_link).each_with_index do |tale_link, index|
      tries = 0
      begin
        tale_page = @agent.get(tale_link)
      rescue => e
        tries += 1
        current_time = Time.now
        File.open("crawlerlog.txt", "a+") do |file|
          file << "#{e} in url #{current_time}\n-----------------------\n"
        end
        retry if tries < 10
      end

      next if tale_page.nil?
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

      tale = Tale.new(name: tale_name, author_id: Author.find_by(name: author_name).id, status: status,
              category_id: Category.find_by(name: category_name).id, source: Settings.url.base_url,
              link: tale_link)
      next unless tale.valid?
      tale.save

      chapter_links = get_all_links(tale_page, "div.danh_sach > a", "div.bt_pagination .next > a")
      if chapter_links.count > 5
        newest_chapters = chapter_links.shift(5)
        chapter_links << newest_chapters.reverse
        chapter_links.flatten!
      end
      get_chapters_content(chapter_links, tale.id)
    end
  end

  def get_chapters_content chapter_links, tale_id
    Chapter.transaction do
      chapter_links.each_with_index do |chap_link, index|
        tries = 0
        begin
          chap_page = @agent.get(chap_link)

          content_html = get_element(chap_page, "td.chi_tiet", TYPE_HTML).squish
          chap_title = get_element(chap_page, "td > h3", TYPE_TEXT).squish

          content_html, content_text = convert_content(content_html)
          chapter_number, title = convert_title(chap_title)

          chapter = Chapter.new(chapter: chapter_number, content_text: content_text,
                      title: title, content_html: content_html, link: chap_link, tale_id: tale_id)

          if chapter.valid?
            if chapter_number.blank?
              chapter_number = Chapter.where(tale_id: tale_id).count + 1
              chapter.chapter = chapter_number
            end
            chapter.save
          end

          puts "Worker_number: #{@class_num} - Title: #{title} - Chapter: #{chapter_number} saved\n"
        rescue => e
          tries += 1
          current_time = Time.now
          File.open("crawlerlog.txt", "a+") do |file|
            file << "#{e} in url #{current_time}\n-----------------------\n"
          end
          retry if tries < 10
        end
      end
    end
  end
end
