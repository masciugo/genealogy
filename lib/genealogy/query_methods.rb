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

    # eligible
    [:father, :mother].each do |parent|
      define_method "eligible_#{parent}s" do
        if send(parent)
          []
        else
          self.class.send("#{Genealogy::PARENT2SEX[parent]}s") - descendants - [self]
        end
      end
    end

    # grandparents
    [:father, :mother].each do |parent|
      [:father, :mother].each do |grandparent|

        # get one
        define_method "#{Genealogy::PARENT2LINEAGE[parent]}_grand#{grandparent}" do
          send(parent) && send(parent).send(grandparent)
        end

        # eligible
        define_method "eligible_#{Genealogy::PARENT2LINEAGE[parent]}_grand#{grandparent}s" do 
          if send(parent) and send("#{Genealogy::PARENT2LINEAGE[parent]}_grand#{grandparent}").nil?
            send(parent).send("eligible_#{grandparent}s") - [self]
          else
            []
          end
        end

      end

      # get two by lineage
      define_method "#{Genealogy::PARENT2LINEAGE[parent]}_grandparents" do
        (send(parent) && send(parent).parents) || []
      end

    end

    def grandparents
      result = []
      [:father, :mother].each do |parent|
        [:father, :mother].each do |grandparent|
          result << send("#{Genealogy::PARENT2LINEAGE[parent]}_grand#{grandparent}")
        end
      end
      result.compact! if result.all?{|gp| gp.nil? }
      result
    end

    # offspring
    def offspring(options = {})

      if spouse = options[:spouse]
        raise WrongSexException, "Something wrong with spouse #{spouse} gender." if spouse.sex == sex 
      end
      case sex
      when sex_male_value
        if spouse
          self.class.find_all_by_father_id_and_mother_id(id,spouse.id)
        else
          self.class.find_all_by_father_id(id)
        end
      when sex_female_value
        if spouse
          self.class.find_all_by_mother_id_and_father_id(id,spouse.id)
        else
          self.class.find_all_by_mother_id(id)
        end
      end
    end

    def eligible_offspring
      self.class.all - ancestors - offspring - siblings - [self]
    end

    # siblings
    def siblings(options = {})
      result = case options[:half]
      when nil # exluding half siblings
        father.try(:offspring, :spouse => mother ).to_a
      when :father # common father
        father.try(:offspring, :spouse => options[:spouse]).to_a - mother.try(:offspring).to_a
      when :mother # common mother
        mother.try(:offspring, :spouse => options[:spouse]).to_a - father.try(:offspring).to_a
      when :only # only half siblings
        siblings(:half => :include) - siblings
      when :include # including half siblings
        father.try(:offspring).to_a + mother.try(:offspring).to_a
      else
        raise WrongOptionValueException, "Admitted values for :half options are: :father, :mother, false, true or nil"
      end
      result.uniq - [self]
    end

    def eligible_siblings
      self.class.all - ancestors - siblings(:half => :include) - [self]
    end

    def half_siblings
      siblings(:half => :only)
      # todo: inprove with option :father and :mother 
    end

    def paternal_half_siblings
      siblings(:half => :father)
    end

    def maternal_half_siblings
      siblings(:half => :mother)
    end

    # ancestors
    def ancestors
      result = []
      remaining = parents.to_a.compact
      until remaining.empty?
        result << remaining.shift
        remaining += result.last.parents.to_a.compact
      end
      result.uniq
    end

    # descendants
    def descendants
      result = []
      remaining = offspring.to_a.compact
      until remaining.empty?
        result << remaining.shift
        remaining += result.last.offspring.to_a.compact
      end
      result.uniq
    end

    def grandchildren
      offspring.inject([]){|memo,child| memo |= child.offspring}
    end

    def uncles_and_aunts
      parents.compact.inject([]){|memo,parent| memo |= parent.siblings}
    end

    def nieces_and_nephews
      siblings.inject([]){|memo,sib| memo |= sib.offspring}
    end

    def family(options = {}) 
      res = [self] | siblings | parents | offspring
      res |= case options[:half]
        when nil
          []
        when :include
          half_siblings
        when :father
          paternal_half_siblings
        when :mother
          maternal_half_siblings
        else
          raise WrongOptionValueException, "Admitted values for :half options are: :father, :mother, :include, nil"
      end
      offspring.inject(res){|memo,child| memo |= child.parents}.compact
    end

    def extended_family(options = {}) 
      (family(options) + grandparents + grandchildren + uncles_and_aunts + nieces_and_nephews).compact
    end

    def is_female?
      sex == sex_female_value
    end

    def is_male?
      sex == sex_male_value  
    end

    module ClassMethods
      def males
        where(sex_column => sex_male_value)
      end
      def females
        where(sex_column => sex_female_value)
      end
    end

  end
end