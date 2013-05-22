module Genealogy
  module QueryMethods
    extend ActiveSupport::Concern

    # parents
    def parents
      if father or mother
        [father,mother]
      else
        []
      end
    end

    # grandparents
    [:father, :mother].each do |parent|
      [:father, :mother].each do |grandparent|

        # get one
        define_method "#{Genealogy::LINEAGE_NAME[parent]}_grand#{grandparent}" do
          send(parent) && send(parent).send(grandparent)
        end

      end

      # get two by lineage
      define_method "#{Genealogy::LINEAGE_NAME[parent]}_grandparents" do
        (send(parent) && send(parent).parents) || []
      end

    end

    # get all
    def grandparents
      result = []
      [:father, :mother].each do |parent|
        [:father, :mother].each do |grandparent|
          result << send("#{Genealogy::LINEAGE_NAME[parent]}_grand#{grandparent}")
        end
      end
      result.compact! if result.all?{|gp| gp.nil? }
      result
    end

    def offspring(options = {})

      if spouse = options[:spouse]
        raise WrongSexException, "Something wrong with spouse #{spouse} gender." if spouse.sex == sex 
      end
      case sex
      when sex_male_value
        self.class.find_all_by_father_id(id, :conditions => (["mother_id == ?", spouse.id] if spouse) )
      when sex_female_value
        self.class.find_all_by_mother_id(id, :conditions => (["father_id == ?", spouse.id] if spouse) )
      end
    end

    def siblings(options = {})
      result = case options[:half]
      when nil # exluding half siblings
        father.try(:offspring, :spouse => mother ).to_a
      when :father # common father
        father.try(:offspring).to_a - mother.try(:offspring).to_a
      when :mother # common mother
        mother.try(:offspring).to_a - father.try(:offspring).to_a
      when :only # only half siblings
        siblings(:half => :include) - siblings
      when :include # including half siblings
        father.try(:offspring).to_a + mother.try(:offspring).to_a
      else
        raise WrongOptionValueException, "Admitted values for :half options are: :father, :mother, false, true or nil"
      end
      result - [self]
    end

    def half_siblings(options = {})
      siblings(:half => :only)
      # todo: inprove with option :father and :mother 
    end

    def ancestors
      result = []
      remaining = parents.to_a.compact
      until remaining.empty?
        result << remaining.shift
        remaining += result.last.parents.to_a.compact
      end
      result.uniq
    end

    def descendants
      result = []
      remaining = offspring.to_a.compact
      until remaining.empty?
        result << remaining.shift
        remaining += result.last.offspring.to_a.compact
      end
      result.uniq
    end


    def is_female?
      sex == sex_female_value
    end

    def is_male?
      sex == sex_male_value  
    end

    module ClassMethods
    end

  end
end