module Genealogy
  # Module UtilMethods provides methods to run utility methods. It's included by the genealogy enabled AR model
  module UtilMethods
    extend ActiveSupport::Concern

    include Constants

    # Genealogy thinks time in term of Date, not DateTime
    # @return [Date]
    def birth
      birth_date.try(:to_date)
    end

    # Genealogy thinks time in term of Date, not DateTime
    # @return [Date]
    def death
      death_date.try(:to_date)
    end

    # optimistic (longest) estimation of life period. Calculation is based on available dates and max life expectancy
    # @return [Range] life period or nil if cannot be computable
    def life_range
      if birth
        if death
          birth..death # exact
        else
          birth..(birth + max_le) # estimation based on birth
        end
      elsif death
        (death - max_le)..death # estimation based on death
      end
    end

    # optimistic (longest) estimation of birth date. Calculation is based on available dates and max life expectancy
    # @return [Range] longest possible birth date interval or nil if cannot be computable
    def birth_range
      if birth
        birth..birth # exact
      elsif death
        (death - max_le)..death # estimation based on death
      end
    end

    # optimistic (longest) estimation of fertility period. Calculation is based on available dates, max life expectancy and min and max fertility procreation ages
    # @return [Range] fertility period, nil if cannot be computable, false if died before reaching min fertility age
    def fertility_range
      if birth
        if death
          if death > birth + min_fpa
            (birth + min_fpa)..([(birth + max_fpa), death].min) # best estimation
          else
            false # died before reaching min fertility age
          end
        else
          (birth + min_fpa)..(birth + max_fpa) # estimation based on birth
        end
      elsif death
        (death - max_le + min_fpa)..death # estimation based on death
      end
    end

    # It tests whether fertility range covers specified date
    # @param [Date] date
    # @return [Boolean] or nil if cannot be computable (#fertility_range returns nil)
    def can_procreate_on?(date)
      fertility_range.cover? date if date and fertility_range
    end

    # It tests whether fertility range overlaps specified period
    # @param [Range] period 
    # @return [Boolean] or nil if cannot be computable (#fertility_range returns nil)
    def can_procreate_during?(period)
      fertility_range.overlaps? period if period and fertility_range
    end

    # @!macro [attach] generate
    #   @method $1_birth_range
    #   optimistic (longest) estimation of $1's birth date. Calculation is based on receiver's birth or #life_range, max life expectancy and min and max fertility procreation ages
    #   @return [Range] longest possible $1's birth date interval or nil when is not computable that is when birth or life range are not available
    def self.generate_method_parent_birth_range(parent)
      define_method "#{parent}_birth_range" do
        if birth
          (birth - gclass.send("max_#{PARENT2SEX[parent]}_procreation_age").years)..(birth - gclass.send("min_#{PARENT2SEX[parent]}_procreation_age").years)
        elsif life_range
          (life_range.begin - gclass.send("max_#{PARENT2SEX[parent]}_procreation_age").years)..(life_range.end - gclass.send("min_#{PARENT2SEX[parent]}_procreation_age").years)
        end
      end
    end
    generate_method_parent_birth_range(:father)
    generate_method_parent_birth_range(:mother)

    # @!macro [attach] generate
    #   @method $1_fertility_range
    #   optimistic (longest) estimation of $1's fertility range. Calculation is based on receiver's #$1_birth_range, min and max fertility procreation ages
    #   @return [Range] longest possible $1's fertility period or nil when is not computable that is when $1_birth_range is not computable
    def self.generate_method_parent_fertility_range(parent)
      define_method "#{parent}_fertility_range" do
        if parent_birth_range = send("#{parent}_birth_range")
          (parent_birth_range.begin + gclass.send("min_#{PARENT2SEX[parent]}_procreation_age").years)..(parent_birth_range.end + gclass.send("max_#{PARENT2SEX[parent]}_procreation_age").years)
        end
      end
    end
    generate_method_parent_fertility_range(:father)
    generate_method_parent_fertility_range(:mother)

    # sex in terms of :male or :female
    # @return [Symbol] 
    def ssex
      case sex
      when gclass.sex_male_value
        :male
      when gclass.sex_female_value
        :female
      else
        raise SexError, "Sex value not valid for #{self}"
      end
    end

    # opposite sex in terms of :male or :female
    # @return [Symbol] 
    def opposite_ssex
      OPPOSITESEX[ssex]
    end

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
    
    # max life expectancy in terms of years. It depends on sex
    # @return [Integer] 
    def max_le
      gclass.send("max_#{ssex}_life_expectancy").years
    end
    
    # max fertility procreation age in terms of years. It depends on sex
    # @return [Integer] 
    def max_fpa
      gclass.send("max_#{ssex}_procreation_age").years
    end
    
    # min fertility procreation age in terms of years. It depends on sex
    # @return [Integer] 
    def min_fpa
      gclass.send("min_#{ssex}_procreation_age").years
    end

    private 

    def check_incompatible_relationship(*args)
      relationship = args.shift
      args.each do |relative|
        # puts "[#{__method__}]: #{arg} class: #{arg.class}, #{self} class: #{self.class}"
        next if relative.nil?
        check_indiv(relative)
        if gclass.ineligibility_level >= PEDIGREE
          if ineligibles = self.send("ineligible_#{relationship.to_s.pluralize}")
            # puts "[#{__method__}]: checking if #{relative} can be #{relationship} of #{self}"
            raise IncompatibleRelationshipException, "#{relative} can't be #{relationship} of #{self}" if ineligibles.include? relative
          else
            raise IncompatibleRelationshipException, "#{self} already has #{relationship}"
          end
        end
      end
    end

    def check_indiv(arg, arg_sex=nil)
      raise ArgumentError, "Expected #{self.gclass} object. Got #{arg.class}" unless arg.class.equal? self.gclass
      raise SexError, "Expected a #{arg_sex} as argument. Got a #{arg.ssex}" if arg_sex and arg.ssex != arg_sex
    end

  end
end