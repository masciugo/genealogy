require "active_record"
require "active_support"
require "logger"
require 'rspec/its'

# this is to make absolutely sure we test this one, not the one
# installed on the system.
require File.expand_path('../../lib/genealogy', __FILE__)

# requiring supporting files like shared examples
Dir["./spec/support/**/*.rb"].sort.each {|f| require f}

RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true
end

module GenealogyTestModel
  def self.connect_to_database
    config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
    ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
    ActiveRecord::Base.establish_connection(config['sqlite3'])
  end

  # method to define TestModel class in the scope of the including module.
  def define_test_model_class has_parents_opts = {}

    # puts "defining TestModel with ActiveRecord version #{Gem::Specification.find_by_name('activerecord').version.to_s}"

    model = Class.new(ActiveRecord::Base) do
      self.table_name = 'test_records'

      has_parents has_parents_opts

      validate :check_invalid

      case  Gem::Specification.find_by_name('activerecord').version.to_s
      when /^3/
        def self.my_find_or_create_by(build_attrs,find_attrs)
          self.find_or_create_by_name(find_attrs.merge(build_attrs))
        end
      when /^4/
        def self.my_find_or_create_by(build_attrs,find_attrs)
          self.create_with(build_attrs).find_or_create_by(find_attrs)
        end
      end


      def inspect
        # "[#{id}]-#{name }"
        "#{name }"
        # "[#{id}-#{object_id}]#{name }"
      end

      def mark_invalid!
        update_attribute(:isinvalid,true)
      end

      private

      def check_invalid
        errors.add(:base, "This object was flagged to always fail") if isinvalid == true
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
      table.integer self::TestModel.current_spouse_column if self::TestModel.current_spouse_enabled?
      table.boolean 'isinvalid'
    end

    self::TestModel.reset_column_information
  end
end


GenealogyTestModel.connect_to_database
