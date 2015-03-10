module Genealogy
  # Module CurrentSpouseMethods provides methods to manage and query current spouse. It's included by the genealogy enabled AR model
  module CurrentSpouseMethods
    extend ActiveSupport::Concern

    include Constants

    # add current spouse updating receiver and argument individuals foreign_key in a transaction
    # @param [Object] spouse
    # @return [Boolean] 
    def add_current_spouse(spouse)

      raise_unless_current_spouse_enabled
      check_incompatible_relationship(:current_spouse,spouse)

      if gclass.perform_validation_enabled
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
      if gclass.perform_validation_enabled
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
      self.gclass.send(ssex.to_s.pluralize)
    end

    private

    def raise_unless_current_spouse_enabled
      raise FeatureNotEnabled, "Spouse tracking not enabled. Enable it with option 'current_spouse_enabled: true' for has_parents method}" unless self.class.current_spouse_enabled
    end

  end
end