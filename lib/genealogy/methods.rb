module Genealogy
  module Methods
    extend ActiveSupport::Concern

    ##################################################################
    ## linking methods
    ##################################################################
    
    # parents 
    [:father, :mother].each do |parent|

      # add method
      define_method "add_#{parent}" do |relative|
        raise IncompatibleObjectException, "Linked objects must be instances of the same class: got #{relative.class} for #{self.class}" unless relative.is_a? self.class
        incompatible_parents = self.offspring | self.siblings.to_a | [self] 
        raise IncompatibleRelationshipException, "#{relative} can't be #{parent} of #{self}" if incompatible_parents.include? relative
        raise WrongSexException, "Can't add a #{relative.sex} #{parent}" unless (parent == :father and relative.is_male?) or (parent == :mother and relative.is_female?)
        send("#{parent}=",relative)
        save!
      end
      
      # remove method
      define_method "remove_#{parent}" do
        send("#{parent}=",nil)
        save!
      end

    end

    # grandparents
    grandparents_lineage_name = { :father => :paternal, :mother => :maternal }
    [:father, :mother].each do |parent|
      [:father, :mother].each do |grandparent|

        # no-bang version
        # add
        define_method "add_#{grandparents_lineage_name[parent]}_grand#{grandparent}" do |relative|
          raise LineageGapException, "#{self} doesn't have #{parent}" unless send(parent)
          raise IncompatibleRelationshipException, "#{self} can't be grand#{grandparent} of itself" if relative == self
          send(parent).send("add_#{grandparent}",relative)
        end

        # remove
        define_method "remove_#{grandparents_lineage_name[parent]}_grand#{grandparent}" do
          raise LineageGapException, "#{self} doesn't have #{parent}" unless send(parent)
          send(parent).send("remove_#{grandparent}")
        end

      end
    end

    ## add siblings
    # no bang version
    def add_siblings(sibs)
      raise LineageGapException, "Can't add siblings if both parents are nil" unless father and mother
      raise IncompatibleRelationshipException, "Can't add an ancestor as sibling" unless (ancestors.to_a & [sibs].flatten).empty?
      transaction do
        [sibs].flatten.each do |sib|
          sib.add_father(self.father)
          sib.add_mother(self.mother)
        end
      end
    end

    # children
    # no bang version
    def add_children(children)
      raise WrongSexException, "Can't add children: undefined sex for #{self}" unless is_male? or is_female?
      transaction do
        [children].flatten.each do |child|
          case sex
          when sex_male_value
            child.add_father(self)
          when sex_female_value
            child.add_mother(self)
          end
        end
      end
    end

    ##################################################################
    ## query methods
    ##################################################################
    
    def parents
      if father or mother
        [father,mother]
      else
        nil
      end
    end

    # grandparents
    [:father, :mother].each do |parent|
      [:father, :mother].each do |grandparent|

        define_method "#{grandparents_lineage_name[parent]}_grand#{grandparent}" do
          raise LineageGapException, "#{self} doesn't have #{parent}" unless send(parent)
          send(parent).send(grandparent)
        end

      end
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

    def offspring
      case sex
      when sex_male_value
        self.class.find_all_by_father_id(id)
      when sex_female_value
        self.class.find_all_by_mother_id(id)
      end
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


    def siblings
      if father and mother
        (father.offspring & mother.offspring) - [self]
      end
    end

    def half_siblings
      if father and mother
        (father.offspring | mother.offspring) - [self] - siblings
      end
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