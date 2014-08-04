module Genealogy
  module QueryMethods
    extend ActiveSupport::Concern

    # parents
    def parents
      [father,mother]
    end

    # eligible
    [:father, :mother].each do |parent|
      define_method "eligible_#{parent}s" do
        if send(parent)
          []
        else
          self.genealogy_class.send("#{Genealogy::PARENT2SEX[parent]}s") - descendants - [self]
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
        (send(parent) && send(parent).parents) || [nil,nil]
      end

    end

    def grandparents
      result = []
      [:father, :mother].each do |parent|
        [:father, :mother].each do |grandparent|
          result << send("#{Genealogy::PARENT2LINEAGE[parent]}_grand#{grandparent}")
        end
      end
      # result.compact! if result.all?{|gp| gp.nil? }
      result
    end

    # offspring
    def offspring(options = {})
      if spouse = options[:spouse]
        raise WrongSexException, "Problems while looking for #{self}'s offspring made with spouse #{spouse} who should not be a #{spouse.sex}." if spouse.sex == sex 
      end
      result = case sex
      when sex_male_value
        if options.keys.include?(:spouse)
          children_as_father.with(spouse.try(:id))
        else
          children_as_father
        end
      when sex_female_value
        if options.keys.include?(:spouse)
          children_as_mother.with(spouse.try(:id))
        else
          children_as_mother
        end
      end
      result.to_a
    end
    alias_method :children, :offspring

    def eligible_offspring
      self.genealogy_class.all - ancestors - offspring - siblings - [self]
    end
    alias_method :eligible_children, :eligible_offspring

    # spouses
    def spouses
      parent_method = Genealogy::SEX2PARENT[Genealogy::OPPOSITESEX[sex_to_s.to_sym]]
      offspring.collect{|child| child.send(parent_method)}.uniq
    end

    def eligible_spouses
      self.genealogy_class.send("#{Genealogy::OPPOSITESEX[sex_to_s.to_sym]}s") - spouses
    end

    # siblings
    def siblings(options = {})
      result = case options[:half]
      when nil # only full siblings
        unless parents.include?(nil)
          father.try(:offspring, :spouse => mother ).to_a
        else
          []
        end
      when :father # common father
        father.try(:offspring, options.keys.include?(:spouse) ? {:spouse => options[:spouse]} : {}).to_a - mother.try(:offspring).to_a
      when :mother # common mother
        mother.try(:offspring, options.keys.include?(:spouse) ? {:spouse => options[:spouse]} : {}).to_a - father.try(:offspring).to_a
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
      self.genealogy_class.all - ancestors - siblings(:half => :include) - [self]
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

    alias_method :eligible_half_siblings, :eligible_siblings
    alias_method :eligible_paternal_half_siblings, :eligible_siblings
    alias_method :eligible_maternal_half_siblings, :eligible_siblings

    # ancestors
    def ancestors
      result = []
      remaining = parents.compact
      until remaining.empty?
        result << remaining.shift
        remaining += result.last.parents.compact
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
        # break if (remaining - result).empty? can be necessary in case of loop. Idem for ancestors method
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
      res |= [current_spouse] if self.class.current_spouse_enabled
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
      res = offspring.inject(res){|memo,child| memo |= child.parents} #add spouses
      
      res += [grandparents + grandchildren + uncles_and_aunts + nieces_and_nephews].flatten if options[:extended]

      res.compact
    end

    def family_hash(options = {}) 
      roles = [:father, :mother, :children, :siblings]
      roles += [:current_spouse] if self.class.current_spouse_enabled
      roles += case options[:half]
        when nil
          []
        when :include
          [:half_siblings]
        when :father
          [:paternal_half_siblings]
        when :mother
          [:maternal_half_siblings]
        else
          raise WrongOptionValueException, "Admitted values for :half options are: :father, :mother, :include, nil"
      end
      roles += [:paternal_grandfather, :paternal_grandmother, :maternal_grandfather, :maternal_grandmother, :grandchildren, :uncles_and_aunts, :nieces_and_nephews] if options[:extended]
      h = {}
      roles.each{|role| h[role] = self.send(role)}
      h
    end

    def extended_family(options = {}) 
      family(options.merge(:extended => true))
    end

    def extended_family_hash(options = {}) 
      family_hash(options.merge(:extended => true))
    end

    def sex_to_s
      case sex
      when sex_male_value
        'male'
      when sex_female_value
        'female'
      else 
        raise "undefined sex for #{self}"
      end
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