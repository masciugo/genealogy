module Genealogy

  def has_parents options = {}

    # Check options
    raise GenealogyOptionException.new("Options for has_parents must be in a hash.") unless options.is_a? Hash
    options.each do |key, value|
      unless [:sex_column, :sex_values, :father_column, :mother_column, :spouse_column, :spouse].include? key
        raise GenealogyOptionException.new("Unknown option for has_parents: #{key.inspect} => #{value.inspect}.")
      end
      if key == :sex_values
        raise GenealogyOptionException, ":sex_values option must be an array with two char: first for male sex symbol an last for female" unless value.is_a?(Array) and value.size == 2 and value.first.to_s.size == 1 and value.last.to_s.size == 1
      end
    end

    
    class_attribute :spouse_enabled
    self.spouse_enabled = options[:spouse].try(:==,true) || false

    tracked_parents = [:father, :mother]
    tracked_parents << :spouse if spouse_enabled

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
    tracked_parents.each do |key|
      # class attribute where is stored the correspondig foreign_key column name
      class_attribute_name = "#{key}_column"
      foreign_key = "#{key}_id"
      class_attribute class_attribute_name
      self.send("#{class_attribute_name}=", options[class_attribute_name.to_sym] || foreign_key)
      
      # self join association
      attr_accessible foreign_key
      belongs_to key, class_name: self, foreign_key: foreign_key
    
    end

    # Include instance methods and class methods
    include Genealogy::Methods
    include Genealogy::SpouseMethods if spouse_enabled

  end
  
end