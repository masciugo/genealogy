require 'simplecov'
SimpleCov.start

require "active_record"
require "active_support"
require "logger"
require "database_cleaner"

DatabaseCleaner.strategy = :truncation

require 'rspec/its'

RSpec.configure do |config|
  config.fail_fast = true
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
  db_config = config[(ENV['GENEALOGY_TEST_DB'] or 'sqlite')]
  puts "connecting to #{db_config['adapter']}"
  ActiveRecord::Base.establish_connection(db_config)
end

def get_test_model has_parents_opts = {}

  klass = Class.new(ActiveRecord::Base) do
    self.table_name = 'test_records'

    validate :check_invalid

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

  klass_name = "TestModel#{rand(10000000000)}"

  # puts "defining #{klass_name} (with options #{has_parents_opts}) as ActiveRecord version #{Gem::Specification.find_by_name('activerecord').version.to_s} "
  Genealogy.const_set klass_name, klass

  klass.has_parents has_parents_opts

  # db setup
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


  klass
end

connect_to_database
