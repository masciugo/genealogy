puts 'loading rspec helper ....'

require "active_record"
require "logger"
require "debugger"

# this is to make absolutely sure we test this one, not the one
# installed on the system.
require File.expand_path('../../lib/genealogy', __FILE__)

# example model classes
require File.expand_path('../test_models', __FILE__)

module Genealogy

  def self.connect_to_database
    config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
    ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
    ActiveRecord::Base.establish_connection(config['sqlite3'])
  end

  def self.set_model_table(model)
    cn = ActiveRecord::Base.connection
    cn.drop_table 'test_records' if cn.table_exists?('test_records')

    cn.create_table 'test_records' do |table|
      table.string :name
      table.string model.sex_column, :size=>1
      table.integer model.father_column
      table.integer model.mother_column
      table.integer model.spouse_column if model.spouse_enabled?
    end

    model.reset_column_information
    model
  end

  # def self.get_test_model has_parents_opts = {}
  #   cn = ActiveRecord::Base.connection
  #   cn.drop_table 'test_records' if cn.table_exists?('test_records')

  #   cn.create_table 'test_records' do |table|
  #     table.string :name
  #     table.integer has_parents_opts[:father_column] || :father_id
  #     table.integer has_parents_opts[:mother_column] || :mother_id
  #     table.integer(has_parents_opts[:spouse_column] || :spouse_id) if has_parents_opts[:spouse] == true
  #   end
    
  #   Class.new(ActiveRecord::Base) do
  #     self.table_name = 'test_records'
  #     self.reset_column_information

  #     attr_accessible :name
      
  #     # has_parents has_parents_opts
      
  #     def to_s
  #       "#{id} - #{name } - #{object_id}"
  #     end
  #   end
  #   # remove_const(:TestModel) if defined?(TestModel)
  #   # const_set 'TestModel', model

  # end
  
end

Genealogy.connect_to_database
