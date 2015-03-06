module Genealogy
  # Module UtilMethods provides methods to run utility methods. It's included by the genealogy enabled AR model
  module UtilMethods
    extend ActiveSupport::Concern

    include Constants

    # @return [Boolean] 
    def is_female?
      return female? if respond_to?(:female?)
      sex == gclass.sex_female_value
    end

    # @return [Boolean] 
    def is_male?
      return male? if respond_to?(:male?)
      sex == gclass.sex_male_value
    end

    # Genealogy thinks time in term of Date, not DateTime
    # @return [Date]
    def birth
      self.send("#{gclass.birth_date_column}").try(:to_date)
    end

    # Genealogy thinks time in term of Date, not DateTime
    # @return [Date]
    def death
      self.send("#{gclass.death_date_column}").try(:to_date)
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

    # If either birth or death are present it's possible to estimate a life range using the life max expectancy
    # @return [Range] 
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


    # If either birth or death are present it's possible to estimate a life range using the min and max procreation ages
    # @return [Range] 
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


    # @!macro [attach] generate
    #   @method $1_birth_range
    #   If life range is definable than it's possible to estimate the $1 life range using the min and max procreation ages
    #   @return [Range]
    def self.generate_method_parent_birth_range(parent)
      define_method "#{parent}_birth_range" do
        if birth
          (birth - max_fpa(PARENT2SEX[parent]))..(birth - min_fpa(PARENT2SEX[parent]))
        elsif life_range
          (life_range.begin - max_fpa(PARENT2SEX[parent]))..(life_range.end - min_fpa(PARENT2SEX[parent]))
        end
      end
    end
    generate_method_parent_birth_range(:father)
    generate_method_parent_birth_range(:mother)

    private

    def max_le(sex=nil)
      gclass.send("max_#{sex or sex_to_s}_life_expectancy").years
    end

    def max_fpa(sex=nil)
      gclass.send("max_#{sex or sex_to_s}_procreation_age").years
    end

    def min_fpa(sex=nil)
      gclass.send("min_#{sex or sex_to_s}_procreation_age").years
    end

    def sex_to_s
      case sex
      when gclass.sex_male_value
        'male'
      when gclass.sex_female_value
        'female'
      else
        raise SexError, "Sex value not valid for #{self}"
      end
    end

    def check_incompatible_relationship(*args)
      relationship = args.shift
      args.each do |relative|
        # puts "[#{__method__}]: #{arg} class: #{arg.class}, #{self} class: #{self.class}"
        next if relative.nil?
        raise ArgumentError, "Expected #{self.gclass} object. Got #{relative.class}" unless relative.class.equal? self.gclass
        if gclass.ineligibility_enabled
          if ineligibles = self.send("ineligible_#{relationship.to_s.pluralize}")
            # puts "[#{__method__}]: checking if #{relative} can be #{relationship} of #{self}"
            raise IncompatibleRelationshipException, "#{relative} can't be #{relationship} of #{self}" if ineligibles.include? relative
          else
            raise IncompatibleRelationshipException, "#{self} already has #{relationship}"
          end
        end
      end
    end

  end
end