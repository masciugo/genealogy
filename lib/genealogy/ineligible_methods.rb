module Genealogy
  module IneligibleMethods
    extend ActiveSupport::Concern

    # parents
    [:father, :mother].each do |parent|
      define_method "ineligible_#{parent}s" do
        if send(parent) # already defined
          genealogy_class.all
        else
          descendants | [self] | genealogy_class.send("#{Genealogy::OPPOSITESEX[Genealogy::PARENT2SEX[parent]]}s")
        end
      end
    end

    # grandparents
    [:father, :mother].each do |parent|
      [:father, :mother].each do |grandparent|
        relationship = "#{Genealogy::PARENT2LINEAGE[parent]}_grand#{grandparent}"
        define_method "ineligible_#{relationship}s" do
          grandparent_sex = Genealogy::PARENT2SEX[grandparent]
          if send("#{relationship}") # already defined
            genealogy_class.all
          else 
            [send(parent)].compact | descendants | [self] | genealogy_class.send("#{Genealogy::OPPOSITESEX[grandparent_sex]}s")
          end
        end

      end

    end

    # children
    def ineligible_children
      ancestors | children | siblings | [self]
    end

    # spouses
    def ineligible_spouses
      spouses | genealogy_class.send("#{sex_to_s}s")
    end

    # siblings
    def ineligible_siblings
      ancestors | descendants | siblings(:half => :include).delete_if{|sib| sib.parents.any?(&:nil?) } | [self]
    end

  end
end