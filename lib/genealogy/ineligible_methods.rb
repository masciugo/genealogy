module Genealogy
  # Module IneligibleMethods provides methods to run genealogy queries to retrive groups of individuals who cannot be relatives according to provided role.
  # It's included by the genealogy enabled AR model
  module IneligibleMethods
    extend ActiveSupport::Concern

    # list of individual who cannot be father
    # @return [Array,NilClass] Return nil if father already assigned
    def ineligible_fathers
      unless father 
        apriori_list = descendants | paternal_half_siblings | [self] | genealogy_class.females
        apriori_list = add_ineligibles_by!(apriori_list) do |remainings|
          # if birth is known ineligible are also all remainings who were fertile and not died by the date self was born
          birth ? remainings.find_all{|i| (i.birth and i.birth + genealogy_class.min_male_procreation_age.years > birth) or (i.death and i.death < birth)} : []
        end
        apriori_list = add_ineligibles_by!(apriori_list) do |remainings|
          # if death is known ineligible are also all remainings who ???? no forse non c'entra niente
          # death ? remainings.find_all{|i| (i.birth and i.birth + genealogy_class.min_male_procreation_age.years > birth) or (i.death and i.death < birth)} : []
        end
      end
    end

    # list of individual who cannot be mother
    # @return [Array,NilClass] Return nil if mother already assigned
    def ineligible_mothers
      unless mother
        apriori_list = descendants | maternal_half_siblings | [self] | genealogy_class.males
        add_ineligibles_by!(apriori_list) do |remainings|
          # if birth is known ineligible are also all remainings who were fertile and not died by the date self was born
          birth ? remainings.find_all{|i| (i.birth and i.birth + genealogy_class.min_female_procreation_age.years > birth) or (i.death and i.death < birth) } : []
        end
      end
    end
    
    # list of individual who cannot be grandfather
    # @return [Array]
    def ineligible_paternal_grandfathers
      [father].compact | descendants | [self] | genealogy_class.females unless paternal_grandfather
    end
    
    # list of individual who cannot be grandmother
    # @return [Array]
    def ineligible_paternal_grandmothers
      [father].compact | descendants | [self] | genealogy_class.males unless paternal_grandmother
    end
    
    # list of individual who cannot be grandfather
    # @return [Array]
    def ineligible_maternal_grandfathers
      [mother].compact | descendants | [self] | genealogy_class.females unless maternal_grandfather
    end
    
    # list of individual who cannot be grandmother
    # @return [Array]
    def ineligible_maternal_grandmothers
      [mother].compact | descendants | [self] | genealogy_class.males unless maternal_grandmother
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

    private

    # @param [Array] apriori_list is the starting list of ineligibles
    # @param [Block] block is a piece of code which must return an array and take as parameters the ramining individuals
    def add_ineligibles_by!(apriori_list,&block)
      if genealogy_class.check_ages_enabled
        yield(genealogy_class.all - apriori_list) + apriori_list
      else
        apriori_list
      end
    end

  end
end