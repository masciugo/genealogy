module Genealogy

  extend ActiveSupport::Concern

  class_methods do

    # gives to ActiveRecord model geneaogy capabilities. Modules UtilMethods QueryMethods IneligibleMethods AlterMethods and SpouseMethods are included
    # @param [Hash] options
    # @option options [Boolean] current_spouse (false) specifies whether to track or not individual's current spouse
    # @option options [Boolean] perform_validation (true) specifies whether to perform validation or not while altering pedigree that is before updating relatives external keys
    # @option options [Boolean, Symbol] ineligibility (:pedigree) specifies ineligibility setting. If `false` ineligibility checks will be disabled and you can assign, as a relative, any individuals you want.
    #   This can be dangerous because you can build nosense loop (in terms of pedigree). If pass one of symbols `:pedigree` or `:pedigree_and_dates` ineligibility checks will be enabled.
    #   More specifically with `:pedigree` (or `true`) checks will be based on pedigree topography, i.e., ineligible children will include ancestors. With `:pedigree_and_dates` check will also be based on
    #   procreation ages (min and max, male and female) and life expectancy (male and female), i.e. an individual born 200 years before is an ineligible mother
    # @option options [Hash] limit_ages (min_male_procreation_age:12, max_male_procreation_age:75, min_female_procreation_age:9, max_female_procreation_age:50, max_male_life_expectancy:110, max_female_life_expectancy:110)
    #   specifies one or more limit ages different than defaults
    # @option options [Hash] column_names (sex:'sex', father_id:'father_id', mother_id:'mother_id', current_spouse_id:'current_spouse_id', birth_date:'birth_date', death_date:'death_date') specifies column names to map database individual table
    # @option options [Array] sex_values (['M','F']) specifies values used in database sex column
    # @return [void]

    def has_parents options = {}

      include Constants
      include UtilMethods
      include QueryMethods
      include ComplexQueryMethods
      include IneligibleMethods
      include AlterMethods
      include CurrentSpouseMethods

      check_has_parents_options(options)

      # instance_variable_set(:@role_as_relative, nil)
      attr_accessor :role_as_relative

      # keep track of the original extend class to prevent wrong scopes in query method in case of STI
      class_attribute :gclass, instance_writer: false
      self.gclass = self

      alias_attribute :id, self.primary_key.to_sym if self.primary_key != 'id'

      self.extend(Genealogy::ComplexQueryMethods::ClassMethods)

      class_attribute :ineligibility_level, instance_accessor: false
      self.ineligibility_level = case options[:ineligibility]
      when :pedigree
        gclass::PEDIGREE
      when true
        gclass::PEDIGREE
      when :pedigree_and_dates
        gclass::PEDIGREE_AND_DATES
      when false
        gclass::OFF
      when nil
        gclass::PEDIGREE
      else
        raise ArgumentError, "ineligibility option must be one among :pedigree, :pedigree_and_dates or false"
      end

      ## limit_ages
      if ineligibility_level >= gclass::PEDIGREE_AND_DATES
        gclass::DEFAULTS[:limit_ages].each do |age,v|
          class_attribute age, instance_accessor: false
          self.send("#{age}=", options[:limit_ages].try(:[],age) || v)
        end
      end

      [:current_spouse, :perform_validation].each do |opt|
        ca = "#{opt}_enabled"
        class_attribute ca, instance_accessor: false
        self.send "#{ca}=", options.key?(opt) ? options[opt] : gclass::DEFAULTS[opt]
      end


      # column names class attributes
      gclass::DEFAULTS[:column_names].merge(options[:column_names]).each do |k,v|
        class_attribute_name = "#{k}_column"
        class_attribute class_attribute_name, instance_accessor: false
        self.send("#{class_attribute_name}=", v)
        alias_attribute k, v unless k == v.to_sym
      end

      ## sex
      class_attribute :sex_values, :sex_male_value, :sex_female_value, instance_accessor: false
      self.sex_values = options[:sex_values] || gclass::DEFAULTS[:sex_values]
      self.sex_male_value = self.sex_values.first
      self.sex_female_value = self.sex_values.last

      # validation
      validates_presence_of :sex
      validates_format_of :sex, with: /[#{sex_values.join}]/

      tracked_relatives = [:father, :mother]
      tracked_relatives << :current_spouse if current_spouse_enabled

      belongs_to_options = {class_name: self.name}
      belongs_to_options[:optional] = true if Gem::Specification.find_by_name('activerecord').version >= Gem::Version.new("5")
      tracked_relatives.each do |k|
        belongs_to k, belongs_to_options.merge(foreign_key: self.send("#{k}_id_column"))
      end

      has_many :children_as_father, class_name: self.name, foreign_key: self.father_id_column, dependent: :nullify
      has_many :children_as_mother, class_name: self.name, foreign_key: self.mother_id_column, dependent: :nullify

    end

  end

end
