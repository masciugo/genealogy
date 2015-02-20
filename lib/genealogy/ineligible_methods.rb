module Genealogy
  # Module IneligibleMethods provides methods to run genealogy queries to retrive groups of individuals who cannot be relatives according to provided role.
  # It's included by the genealogy enabled AR model
  module IneligibleMethods
    extend ActiveSupport::Concern

    include Constants

    # @!macro [attach] generate
    #   @method ineligible_$1s
    #   list of individual who cannot be $1 
    #   @return [Array,NilClass] Return nil if $1 already assigned
    def self.generate_method_ineligibles_parent(parent)
      define_method "ineligible_#{parent}s" do
        unless self.send(parent) 
          ineligibles = descendants | siblings | self.send("#{PARENT2LINEAGE[parent]}_half_siblings") | [self] | genealogy_class.send("#{OPPOSITESEX[PARENT2SEX[parent]]}s")
          if genealogy_class.check_ages_enabled and life_range
            ineligibles += (genealogy_class.all - ineligibles).find_all do |indiv|
              if indiv.life_range
                if birth
                  !indiv.can_procreate_on?(birth)
                else
                  !indiv.can_procreate_during?(life_range)
                end
              else
                false
              end
            end
          end
          ineligibles
        end
      end
    end
    generate_method_ineligibles_parent(:father)
    generate_method_ineligibles_parent(:mother)


    # # list of individual who cannot be grandfather
    # # @return [Array]
    # def ineligible_paternal_grandfathers
    #   unless paternal_grandfather
    #     ineligibles = [father].compact | descendants | siblings(half: :include) | [self] | genealogy_class.females
    #     if genealogy_class.check_ages_enabled
    #       ineligibles += if father
    #         father.ineligible_fathers
    #       else
    #         (genealogy_class.all - ineligibles).find_all do |indiv|
    #           if indiv.life_range
    #             !indiv.can_procreate_during?(parent_birth_range)
    #           else
    #             false
    #           end
    #         end
    #       end
    #     end
    #     ineligibles
    #   end
    # end
    
    # list of individual who cannot be grandfather
    # @return [Array]
    def ineligible_paternal_grandfathers
      [father].compact | descendants | siblings(half: :include) | [self] | genealogy_class.females unless paternal_grandfather
    end
    
    # list of individual who cannot be grandmother
    # @return [Array]
    def ineligible_paternal_grandmothers
      [father].compact | descendants | siblings(half: :include) | [self] | genealogy_class.males unless paternal_grandmother
    end
    
    # list of individual who cannot be grandfather
    # @return [Array]
    def ineligible_maternal_grandfathers
      [mother].compact | descendants | siblings(half: :include) | [self] | genealogy_class.females unless maternal_grandfather
    end
    
    # list of individual who cannot be grandmother
    # @return [Array]
    def ineligible_maternal_grandmothers
      [mother].compact | descendants | siblings(half: :include) | [self] | genealogy_class.males unless maternal_grandmother
    end

    # list of individual who cannot be children: ancestors, children, full siblings and theirself
    # @return [Array]
    def ineligible_children
      ancestors | children | siblings | [self]
    end

    # list of individual who cannot be siblings: ancestors, descendants, half siblings with an undefined parent and theirself
    # @return [Array]
    def ineligible_siblings
      ancestors | descendants | genealogy_class.indivs_with_parents | [self]
    end

    private

  end
end