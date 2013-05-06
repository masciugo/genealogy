module Genealogy
  module SpouseMethods
    extend ActiveSupport::Concern

    def add_spouse(arg)
      if arg.is_a? Hash
        build_spouse arg
      elsif arg.is_a? self.class
        self.spouse = arg
      end
    end

    def add_spouse!(arg)
      add_spouse arg
      save!
    end

    module ClassMethods
    end

  end
end