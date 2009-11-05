$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'rubygems'
if ENV['RAILS'].nil?
  require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))
else
  # specific rails version targeted
  # load activerecord and plugin manually
  gem 'activerecord', "=#{ENV['RAILS']}"
  require 'active_record'
  ActiveRecord.load_all!
  require 'active_record/associations'
  Dir["#{File.join(File.dirname(__FILE__), '..', 'lib')}/**/*.rb"].each do |path|
    require path
  end
  require File.join(File.dirname(__FILE__), '..', 'init.rb')
end
require 'active_record/fixtures'

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
# do this so fixtures will load
ActiveRecord::Base.configurations.update config 
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'sqlite3'])

models_dir = File.join(File.dirname(__FILE__), 'app/models')
Dir["#{models_dir}/**/*.rb"].each do |path|
  model = path[models_dir.size+1..-4]
  autoload model.classify.to_sym, "#{models_dir}/#{model}"
end
load(File.dirname(__FILE__) + "/schema.rb")

class ActiveSupport::TestCase #:nodoc:
  include ActiveRecord::TestFixtures
  self.fixture_path = File.dirname(__FILE__) + "/fixtures/"
  
  def create_fixtures(*table_names)
    if block_given?
      Fixtures.create_fixtures(self.class.fixture_path, table_names) { yield }
    else
      Fixtures.create_fixtures(self.class.fixture_path, table_names)
    end
  end

  # Turn off transactional fixtures if you're working with MyISAM tables in MySQL
  self.use_transactional_fixtures = true
  
  # Instantiated fixtures are slow, but give you @david where you otherwise would need people(:david)
  self.use_instantiated_fixtures  = false

  # Add more helper methods to be used by all tests here...
end
