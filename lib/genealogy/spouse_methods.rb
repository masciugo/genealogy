module Genealogy
  module SpouseMethods
    extend ActiveSupport::Concern

   ## no-bang version
   # add method
   def add_spouse(obj)
      raise IncompatibleObjectException, "Linked objects must be instances of the same class" unless obj.is_a? self.class
      raise WrongSexException, "Can't add spouse with same sex" if self.sex == obj.sex
      self.spouse = obj
      obj.spouse = self
    end

    # remove method
    def remove_spouse
      spouse.spouse = nil
      self.spouse = nil
    end

    ## bang version
    # add method
    def add_spouse!(obj)
      transaction do
        add_spouse obj
        obj.save!
        save!
      end
    end

    # remove method
    def remove_spouse!
      transaction do
        ex_spouse = spouse
        remove_spouse
        ex_spouse.save!
        save!
      end
    end

    module ClassMethods
    end

  end
end