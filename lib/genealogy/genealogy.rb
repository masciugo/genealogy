module Genealogy

  def has_parents options = {}

    # Check options
    raise GenericException.new("Options for has_parents must be in a hash.") unless options.is_a? Hash
    options.each do |key, value|
      unless [:father_column, :mother_column, :spouse_column, :spouse].include? key
        raise GenericException.new("Unknown option for has_parents: #{key.inspect} => #{value.inspect}.")
      end
    end
    
    class_attribute :spouse_enabled
    self.spouse_enabled = true if options[:spouse].try(:==,true)

    tracked_parents = [:father, :mother]
    tracked_parents << :spouse if spouse_enabled

    tracked_parents.each do |key|

      # class attribute where is stored the correspondig foreign_key column name
      class_attribute_name = "#{key}_column"
      foreign_key = "#{key}_id"
      class_attribute class_attribute_name
      self.send("#{class_attribute_name}=", options[class_attribute_name.to_sym] || foreign_key)
      
      # self join association
      attr_accessor foreign_key
      belongs_to key, class_name: self, foreign_key: foreign_key
    
    end

    # Include instance methods and class methods
    include Genealogy::Methods
    include Genealogy::SpouseMethods if spouse_enabled

    # puts "Genealogy loaded with options: #{options.inspect}"

  end
  
end