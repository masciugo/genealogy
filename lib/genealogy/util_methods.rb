module Genealogy
  # Module UtilMethods provides methods to run utility methods. It's included by the genealogy enabled AR model
  module UtilMethods
    extend ActiveSupport::Concern

    # @return [Boolean] 
    def is_female?
      return female? if respond_to?(:female?)
      sex == sex_female_value
    end

    # @return [Boolean] 
    def is_male?
      return male? if respond_to?(:male?)
      sex == sex_male_value
    end

    # Genealogy thinks time in term of Date, not DateTime
    # @return [Date]
    def birth
      self.send("#{genealogy_class.birth_date_column}").try(:to_date)
    end

    # Genealogy thinks time in term of Date, not DateTime
    # @return [Date]
    def death
      self.send("#{genealogy_class.death_date_column}").try(:to_date)
    end

    # According to procreation ages says if self can procreate at specified time
    # @param [Date] date
    # @return [Boolean] 
    def can_procreate_on?(date)
      fertility_range.cover? date if fertility_range
    end

    # According to procreation ages says if self can procreate at specified time
    # @param [Range] period is a range of dates
    # @return [Boolean] 
    def can_procreate_during?(period)
      fertility_range.overlaps? period if fertility_range
    end

    def died_at
      death - birth 
    end

    def life_range
      case [birth.present?,death.present?]
      when [true,true]
        birth..death
      when [true,false]
        birth..(birth + max_le)
      when [false,true]
        (death - max_le)..death
      end
    end

    def fertility_range
      case [birth.present?,death.present?]
      when [true,true]
        (birth + min_fpa)..([(birth + max_fpa), death].min)
      when [true,false]
        (birth + min_fpa)..(birth + max_fpa)
      when [false,true]
        (death - max_le + min_fpa)..death
      end
    end

    def parent_birth_range
      (life_range.begin - max_fpa)..(life_range.begin - min_fpa) if life_range
    end

    private

    def max_le
      genealogy_class.send("max_#{sex_to_s}_life_expectancy").years
    end

    def max_fpa
      genealogy_class.send("max_#{sex_to_s}_procreation_age").years
    end

    def min_fpa
      genealogy_class.send("min_#{sex_to_s}_procreation_age").years
    end

    def sex_to_s
      case sex
      when sex_male_value
        'male'
      when sex_female_value
        'female'
      else
        raise SexError, "Sex value not valid for #{self}"
      end
    end

  end
end