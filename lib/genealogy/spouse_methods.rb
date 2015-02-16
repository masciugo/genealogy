module Genealogy
  # Module SpouseMethods provides methods to manage and query current spouse. It's included by the genealogy enabled AR model
  module SpouseMethods
    extend ActiveSupport::Concern

    include Constants

    # add current spouse updating receiver and argument individuals foreign_key in a transaction
    # @param [Object] spouse
    # @return [Boolean] 
    def add_current_spouse(spouse)
      raise_unless_current_spouse_enabled
      raise ArgumentError, "Expected #{self.genealogy_class} spouse. Got #{spouse.class}" unless spouse.class.respond_to?(:genealogy_enabled)
      raise IncompatibleRelationshipException, "#{spouse} can't be spouse of #{self}" if ineligible_current_spouses.include? spouse

      if perform_validation
        self.current_spouse = spouse
        spouse.current_spouse = self
        transaction do
          spouse.save!
          save!
        end
      else
        transaction do
          self.update_attribute(:current_spouse,spouse)
          spouse.update_attribute(:current_spouse,self)
        end
      end

    end

    # remove current spouse resetting receiver and argument individuals foreign_key in a transaction
    # @return [Boolean] 
    def remove_current_spouse
      raise_unless_current_spouse_enabled
      if perform_validation
        ex_current_spouse = current_spouse
        current_spouse.current_spouse = nil
        self.current_spouse = nil
        transaction do
          ex_current_spouse.save!
          save!
        end
      else
        transaction do
          current_spouse.update_attribute(:current_spouse,nil)
          self.update_attribute(:current_spouse,nil)
        end
      end
    end

    # list of individual who cannot be current spouse
    # @return [Array]
    def ineligible_current_spouses
      raise_unless_current_spouse_enabled
      self.genealogy_class.send(sex_to_s.pluralize) + spouses
    end

    private

    def raise_unless_current_spouse_enabled
      raise FeatureNotEnabled, "Spouse tracking not enabled. Enable it with option 'current_spouse_enabled: true' for has_parents method}" unless self.class.current_spouse_enabled
    end

  end
end