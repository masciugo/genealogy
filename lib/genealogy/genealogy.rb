module Genealogy

  def check_options(options, admitted_keys)

    raise WrongArgumentException, "first argument must be in a hash." unless options.is_a? Hash
    raise WrongArgumentException, "seconf argument must be in an array." unless admitted_keys.is_a? Array

    options.each do |key, value|
      unless admitted_keys.include? key
        raise WrongOptionException.new("Unknown option: #{key.inspect} => #{value.inspect}.")
      end
      if block_given?
        yield key, value
      end
    end

  end


  def has_parents options = {}

    admitted_keys = [:sex_column, :sex_values, :father_column, :mother_column, :current_spouse_column, :current_spouse]
    check_options(options, admitted_keys) do |key, value|
      if key == :sex_values
        raise WrongOptionException, ":sex_values option must be an array with two char: first for male sex symbol an last for female" unless value.is_a?(Array) and value.size == 2 and value.first.to_s.size == 1 and value.last.to_s.size == 1
      end
    end
    
    class_attribute :genealogy_enabled, :current_spouse_enabled, :genealogy_class
    self.genealogy_enabled = true
    self.current_spouse_enabled = options[:current_spouse].try(:==,true) || false
    self.genealogy_class = self #keep track of the original extend class to prevent wrong scopes in query method in case of STI
    
    tracked_relatives = [:father, :mother]
    tracked_relatives << :current_spouse if current_spouse_enabled

    ## sex
    # class attributes
    class_attribute :sex_column, :sex_values, :sex_male_value, :sex_female_value
    self.sex_column = options[:sex_column] || :sex
    self.sex_values = (options[:sex_values] and options[:sex_values].to_a.map(&:to_s)) || ['M','F']
    self.sex_male_value = self.sex_values.first
    self.sex_female_value = self.sex_values.last
    # instance attribute
    alias_attribute :sex, sex_column if self.sex_column != :sex
    # validation
    validates_presence_of sex_column
    validates_format_of sex_column, :with => /[#{sex_values.join}]/ 

    ## relatives associations
    tracked_relatives.each do |key|
      # class attribute where is stored the correspondig foreign_key column name
      class_attribute_name = "#{key}_column"
      foreign_key = "#{key}_id"
      class_attribute class_attribute_name
      self.send("#{class_attribute_name}=", options[class_attribute_name.to_sym] || foreign_key)
      
      # self join association
      belongs_to key, class_name: self, foreign_key: foreign_key
    
    end

    # Include instance methods and class methods
    include Genealogy::QueryMethods
    include Genealogy::AlterMethods
    include Genealogy::SpouseMethods if current_spouse_enabled

  end
  
end