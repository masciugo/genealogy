require "active_record"
require "logger"
require "debugger"

# this is to make absolutely sure we test this one, not the one
# installed on the system.
require File.expand_path('../../lib/genealogy', __FILE__)

module GenealogyTestModel
  def self.connect_to_database
    config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
    ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
    ActiveRecord::Base.establish_connection(config['sqlite3'])
  end

  # method to define TestModel class in the scope of the including module.
  def define_test_model_class has_parents_opts = {}

    model = Class.new(ActiveRecord::Base) do
      self.table_name = 'test_records'

      has_parents has_parents_opts

      attr_accessible :name, :sex

      attr_accessor :always_fail_validation
      validate :check_always_fail_validation

      def to_s
        "#{id} - #{name } - #{object_id}"
      end

      private

      def check_always_fail_validation
        errors.add(:base, "This object was flagged to always fail") if @always_fail_validation == true
      end

    end

    remove_const(:TestModel) if defined?(self::TestModel)
    self.const_set 'TestModel', model
    
    cn = ActiveRecord::Base.connection
    cn.drop_table 'test_records' if cn.table_exists?('test_records')

    cn.create_table 'test_records' do |table|
      table.string :name
      table.string self::TestModel.sex_column, :size=>1
      table.integer self::TestModel.father_column
      table.integer self::TestModel.mother_column
      table.integer self::TestModel.spouse_column if self::TestModel.spouse_enabled?
    end

    self::TestModel.reset_column_information
  end
end

GenealogyTestModel.connect_to_database
