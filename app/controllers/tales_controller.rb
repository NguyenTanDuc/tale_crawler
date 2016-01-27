class TalesController < ApplicationController
  include TalesHelper
  include MechanizeHelper

  before_action :setup_mechanize
  def index

  end

  def new
    home_page = @agent.get(Settings.url.base_url)
    links = get_element(home_page, "div#content ul.content li > a:nth-child(2)", TYPE_HREF)
    all_tale_links = get_all_links(home_page, "div#content ul.content li > a:nth-child(2)", "div.bt_pagination .next > a")
    all_tale_links.each do |tale_link|
      TaleLink.create! tale_link: tale_link
    end
    Settings.worker.number.times do |n|
      TaleCrawlerWorker.perform_async(n + 1)
    end
  end

  private
  def setup_mechanize
    Sidekiq::Queue.new.clear
    Sidekiq::RetrySet.new.clear
    Sidekiq::ScheduledSet.new.clear

    @agent = Mechanize.new
    @agent.user_agent_alias = "Mac Safari"
    @agent.ignore_bad_chunking = true
    @agent.keep_alive = false
  end
end
