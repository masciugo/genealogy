module Genealogy
  module Methods
    extend ActiveSupport::Concern

    def foo
      'InstanceMethods#foo'
    end
    
    # add parents methods
    [:father, :mother].each do |parent|

      ## no-bang version
      # add method
      define_method "add_#{parent}" do |obj|
        raise IncompatibleObjectException, "Linked objects must be instances of the same class: got #{obj.class} for #{self.class}" unless obj.is_a? self.class
        send("#{parent}=",obj)
      end
      
      # remove method
      define_method "remove_#{parent}" do
        send("#{parent}=",nil)
      end

      # bang version
      # add method
      define_method "add_#{parent}!" do |obj|
        send("add_#{parent}",obj)
        save!
      end

      # remove method
      define_method "remove_#{parent}!" do 
        send("remove_#{parent}")
        save!
      end

    end

    # grandparents
    translation = { :father => :paternal, :mother => :maternal }
    [:father, :mother].each do |parent|
      [:father, :mother].each do |grandparent|

        # query methods

        define_method "#{translation[parent]}_grand#{grandparent}" do
          raise LineageGapException, "#{self} doesn't have #{parent}" unless send(parent)
          send(parent).send(grandparent)
        end

        # add methods
        
        # no-bang version
        define_method "add_#{translation[parent]}_grand#{grandparent}" do |obj|
          raise LineageGapException, "#{self} doesn't have #{parent}" unless send(parent)
          if obj.is_a? Hash
            send(parent).send("build_#{grandparent}",obj)
          elsif obj.is_a? self.class
            send(parent).send("#{grandparent}=",obj)
          end
        end

        # bang version
        define_method "add_#{translation[parent]}_grand#{grandparent}!" do |obj|
          raise LineageGapException, "#{self} doesn't have #{parent}" unless send(parent)
          send(parent).send("add_#{grandparent}",obj)
          send(parent).save!
        end

      end
    end

    def offspring
      case sex
      when sex_male_value
        self.class.find_all_by_father_id(id)
      when sex_female_value
        self.class.find_all_by_mother_id(id)
      end
    end

    def siblings
      if father and mother
        (father.offspring & mother.offspring) - [self]
      end
    end

    def half_siblings
      if father and mother
        (father.offspring | mother.offspring) - [self] - siblings
      end
    end

    def add_siblings(sibs)
      raise LineageGapException, "Can't add siblings if both parents are nil" unless father and mother
      [sibs].flatten.each do |sib|
        sib.add_father(self.father)
        sib.add_mother(self.mother)
      end
    end

    def add_siblings!(sibs)
      transaction do
        add_siblings(sibs)
        [sibs].flatten.each { |s| s.save! }
        save!
      end
    end


    module ClassMethods
    end

  end
end