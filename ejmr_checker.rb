require 'mechanize'
require './ejmr_checker_config'
require './new_posts_notifier'

# EjmrChecker
class EjmrChecker
  PAGE_URI = 'https://www.econjobrumors.com/topic/marketing-job-market-2019/page/'.freeze

  def initialize
    @agent = Mechanize.new
    @config = EjmrCheckerConfig.new
  end

  def check
    new_posts = load_new_posts
    notify_new_posts(new_posts)
    config.save
  end

  private

  attr_reader :config

  def load_new_posts # rubocop:disable Metrics/MethodLength
    current_page = config.last_page

    new_posts = []
    loop do
      posts = load_posts_in_page(current_page)
      break if posts.empty?

      current_new_posts = filter_new_posts(posts)
      new_posts.concat(current_new_posts)

      config.last_post_id = posts.last[:id]
      config.last_page = current_page
      current_page += 1
    end

    new_posts
  end

  def load_posts_in_page(page)
    @agent.get("#{PAGE_URI}#{page}")
    dom_posts = @agent.page.xpath("//li[contains(@id, 'post-')]")
    dom_posts.map do |dom_post|
      id = dom_post.attr('id')[5..-1].to_i
      content = dom_post.xpath(".//div[@class='post']").inner_html
      { id: id, content: content }
    end
  end

  def filter_new_posts(posts)
    if config.last_post_id
      posts.select { |p| p[:id] > config.last_post_id }
    else
      posts
    end
  end

  def notify_new_posts(posts)
    NewPostsNotifier.new.notify(posts)
  end
end
