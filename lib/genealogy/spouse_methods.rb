module Genealogy
  module SpouseMethods
    extend ActiveSupport::Concern

    # add method
    def add_spouse(obj)
      raise IncompatibleObjectException, "Linked objects must be instances of the same class" unless obj.is_a? self.class
      raise WrongSexException, "Can't add spouse with same sex" if self.sex == obj.sex
      self.spouse = obj
      obj.spouse = self
      transaction do
        obj.save!
        save!
      end
    end

    # remove method
    def remove_spouse
      transaction do
        ex_spouse = spouse
        spouse.spouse = nil
        self.spouse = nil
        ex_spouse.save!
        save!
      end
    end

    module ClassMethods
    end

  end
end