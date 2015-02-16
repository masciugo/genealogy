module Genealogy
  # Module IneligibleMethods provides methods to run genealogy queries to retrive groups of individuals who cannot be relatives according to provided role.
  # It's included by the genealogy enabled AR model
  module IneligibleMethods
    extend ActiveSupport::Concern

    # list of individual who cannot be father
    # @return [Array]
    def ineligible_fathers
      father ? genealogy_class.all : (descendants | [self] | genealogy_class.females)
    end

    # list of individual who cannot be mother
    # @return [Array]
    def ineligible_mothers
      mother ? genealogy_class.all : (descendants | [self] | genealogy_class.males)
    end
    
    # list of individual who cannot be grandfather
    # @return [Array]
    def ineligible_paternal_grandfathers
      paternal_grandfather ? genealogy_class.all : ([father].compact | descendants | [self] | genealogy_class.females)
    end
    
    # list of individual who cannot be grandmother
    # @return [Array]
    def ineligible_paternal_grandmothers
      paternal_grandmother ? genealogy_class.all : ([father].compact | descendants | [self] | genealogy_class.males)
    end
    
    # list of individual who cannot be grandfather
    # @return [Array]
    def ineligible_maternal_grandfathers
      maternal_grandfather ? genealogy_class.all : ([mother].compact | descendants | [self] | genealogy_class.females)
    end
    
    # list of individual who cannot be grandmother
    # @return [Array]
    def ineligible_maternal_grandmothers
      maternal_grandmother ? genealogy_class.all : ([mother].compact | descendants | [self] | genealogy_class.males)
    end

    # list of individual who cannot be children
    # @return [Array]
    def ineligible_children
      ancestors | children | siblings | [self]
    end

    # list of individual who cannot be spouses
    # @return [Array]
    def ineligible_spouses
      spouses | genealogy_class.send("#{sex_to_s}s")
    end

    # list of individual who cannot be siblings
    # @return [Array]
    def ineligible_siblings
      ancestors | descendants | siblings(:half => :include).delete_if{|sib| sib.parents.any?(&:nil?) } | [self]
    end

  end
end