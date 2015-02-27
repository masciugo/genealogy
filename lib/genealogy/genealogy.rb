module Genealogy

  extend ActiveSupport::Concern

  module ClassMethods
    
    include Genealogy::Constants

    # gives to ActiveRecord model geneaogy capabilities. Modules UtilMethods QueryMethods IneligibleMethods AlterMethods and SpouseMethods are included
    # @param [Hash] options
    # @option options [Boolean] current_spouse (false) change to true to track individual's current spouse
    # @option options [Boolean] perform_validation (true) change to false to update relatives external keys without perform validation
    # @option options [Hash] column_names (sex: 'sex', father_id: 'father_id', mother_id: 'mother_id', current_spouse_id: 'current_spouse_id', birth_date: 'birth_date', death_date: 'death_date') column names to map database individual table
    # @option options [Array] sex_values (['M','F']) values used in database sex column 
    # @return [void] 
    def has_parents options = {}

      check_options(options)

      # keep track of the original extend class to prevent wrong scopes in query method in case of STI
      class_attribute :genealogy_class
      self.genealogy_class = self 
      
      class_attribute :check_ages_enabled
      self.check_ages_enabled = options[:check_ages].try(:==,false) ? false : true
      
      [:current_spouse, :perform_validation, :replace_parent].each do |opt|
        ca = "#{opt}_enabled"
        class_attribute ca
        self.send "#{ca}=", options.key?(opt) ? options[opt] : DEFAULTS[opt]
      end


      # column names class attributes
      DEFAULTS[:column_names].merge(options[:column_names]).each do |k,v|
        class_attribute_name = "#{k}_column"
        class_attribute class_attribute_name
        self.send("#{class_attribute_name}=", v)
      end
      alias_attribute :sex, sex_column unless sex_column == 'sex'

      ## sex
      class_attribute :sex_values, :sex_male_value, :sex_female_value
      self.sex_values = options[:sex_values] || DEFAULTS[:sex_values]
      self.sex_male_value = self.sex_values.first
      self.sex_female_value = self.sex_values.last
      
      ## ages
      if check_ages_enabled
        DEFAULTS[:check_ages].each do |age,v|
          class_attribute age
          self.send("#{age}=", options[:check_ages].try(:[],age) || v)
        end
      end
      
      # validation
      validates_presence_of sex_column
      validates_format_of sex_column, :with => /[#{sex_values.join}]/

      tracked_relatives = [:father, :mother]
      tracked_relatives << :current_spouse if current_spouse_enabled
      tracked_relatives.each do |k|
        belongs_to k, class_name: self, foreign_key: self.send("#{k}_id_column")
      end

      has_many :children_as_father, :class_name => self, :foreign_key => self.father_id_column, :dependent => :nullify, :extend => FatherAssociationExtension
      has_many :children_as_mother, :class_name => self, :foreign_key => self.mother_id_column, :dependent => :nullify, :extend => MotherAssociationExtension

      include Genealogy::UtilMethods
      include Genealogy::QueryMethods
      include Genealogy::IneligibleMethods
      include Genealogy::AlterMethods
      include Genealogy::SpouseMethods

    end

    private

    module MotherAssociationExtension
      def with(father_id)
        where(father_id: father_id)
      end
    end
    module FatherAssociationExtension
      def with(mother_id)
        where(mother_id: mother_id)
      end
    end

    def check_options(options)

      raise ArgumentError, "Hash expected, #{options.class} given." unless options.is_a? Hash

      # column names
      options[:column_names] ||= {}
      raise ArgumentError, "Hash expected for :column_names option, #{options[:column_names].class} given." unless options[:column_names].is_a? Hash

      # sex
      if array = options[:sex_values]
        raise ArgumentError, ":sex_values option must be an array of length 2: [:male_value, :female_value]" unless array.is_a?(Array) and array.size == 2
      end

      # booleans
      options.slice(:perform_validation, :current_spouse).each do |k,v|
        raise ArgumentError, "Boolean expected for #{k} option, #{v.class} given." unless !!v == v
      end
    end

  end

end