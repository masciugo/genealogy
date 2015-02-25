require "active_record"
require "active_support"
require "logger"
require "database_cleaner"

DatabaseCleaner.strategy = :truncation

case RUBY_VERSION
when /^1.9/
  require "debugger"
when /^2/
  require "byebug"
else
  raise  
end

require 'rspec/its'

RSpec.configure do |config|
  # config.fail_fast = false
  # config.order = "random" # examples are are not ready for this
  config.color = true
  config.formatter = :documentation
end

# this is to make absolutely sure we test this one, not the one
# installed on the system.
require File.expand_path('../../lib/genealogy', __FILE__)

# requiring supporting files like shared examples
Dir["./spec/support/**/*.rb"].sort.each {|f| require f}

def connect_to_database
  config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
  ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
  ActiveRecord::Base.establish_connection(config['sqlite3'])
end

def get_test_model has_parents_opts = {}

  klass = Class.new(ActiveRecord::Base) do
    self.table_name = 'test_records'

    has_parents has_parents_opts

    validate :check_invalid

    def self.my_find_by_name(name)
      case  Gem::Specification.find_by_name('activerecord').version.to_s
      when /^3/
        self.find_by_name(name)
      when /^4/
        self.find_by(name: name)
      else
        raise 'unknown activerecord version'
      end
    end

    def inspect
      # "[#{id}]-#{name }"
      to_s
      # "[#{id}-#{object_id}]#{name }"
    end

    def to_s
      # "[#{id}] #{name }"
      name
    end

    def mark_invalid!
      update_attribute(:isinvalid,true)
    end

    private

    def check_invalid
      errors.add(:base, "This object was flagged to always fail") if isinvalid == true
    end

  end

  cn = ActiveRecord::Base.connection
  cn.drop_table 'test_records' if cn.table_exists?('test_records')

  cn.create_table 'test_records' do |table|
    table.string :name
    if klass.sex_male_value.is_a? Integer
      table.integer klass.sex_column
    else
      table.string klass.sex_column
    end
    table.integer klass.father_id_column
    table.integer klass.mother_id_column
    table.datetime klass.birth_date_column
    table.datetime klass.death_date_column 
    table.integer klass.current_spouse_id_column if klass.current_spouse_enabled?
    table.boolean 'isinvalid'
  end

  klass.reset_column_information

  klass_name = "TestModel#{rand(10000000000)}"

  # puts "defining #{klass_name} (with options #{has_parents_opts}) as ActiveRecord version #{Gem::Specification.find_by_name('activerecord').version.to_s} "
  Genealogy.const_set klass_name, klass
end

connect_to_database
