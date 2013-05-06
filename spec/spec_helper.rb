require "active_record"
require "logger"
require "debugger"

# this is to make absolutely sure we test this one, not the one
# installed on the system.
require File.expand_path('../../lib/genealogy', __FILE__)

def load_schema
  config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
  ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
  ActiveRecord::Base.establish_connection(config['sqlite3'])
  load(File.dirname(__FILE__) + "/schema.rb")
end

def reset_individual_class
  Object.send(:remove_const, 'Individual')
  load File.join('test_models','individual.rb')
end

def ppp(str)
  puts ">>>>>>>>>>>>>>>>> #{str} "
end

# example model classes
Dir[File.dirname(__FILE__) + "/test_models/*.rb"].sort.each { |f| require File.expand_path(f) }

