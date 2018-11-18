require 'yaml'

# EjmrCheckerConfig
class EjmrCheckerConfig
  attr_accessor :last_page, :last_post_id

  CONFIG_FILE = 'ejmr_checker_config.yml'.freeze

  def initialize
    load
  end

  def save
    File.open(CONFIG_FILE, 'w') do |f|
      yaml = YAML.dump(
        'last_page' => @last_page,
        'last_post_id' => @last_post_id
      )
      f.write(yaml)
    end
  end

  private

  DEFAULT_LAST_PAGE = 100
  def load
    if File.exist?(CONFIG_FILE)
      yaml = YAML.load_file(CONFIG_FILE)
      @last_page = yaml['last_page']
      @last_post_id = yaml['last_post_id']
    end
    @last_page ||= DEFAULT_LAST_PAGE
    true
  end
end
