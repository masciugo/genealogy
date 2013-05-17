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
        unless relative.nil?
          raise IncompatibleObjectException, "Linked objects must be instances of the same class: got #{relative.class} for #{self.class}" unless relative.is_a? self.class
          incompatible_parents = self.offspring | self.siblings.to_a | [self] 
          raise IncompatibleRelationshipException, "#{relative} can't be #{parent} of #{self}" if incompatible_parents.include? relative
          raise WrongSexException, "Can't add a #{relative.sex} #{parent}" unless (parent == :father and relative.is_male?) or (parent == :mother and relative.is_female?)
        end
        self.send("#{parent}=",relative)
        save!
      end
      
      # remove method
      define_method "remove_#{parent}" do
        self.send("#{parent}=",nil)
        save!
      end

    end

    # add both
    def add_parents(father,mother)
      transaction do
        add_father(father)
        add_mother(mother)
      end
    end

    # remove both
    def remove_parents
      transaction do
        remove_father
        remove_mother
      end
    end

    # grandparents
    LINEAGE_NAME = { :father => :paternal, :mother => :maternal }
    [:father, :mother].each do |parent|
      [:father, :mother].each do |grandparent|
        # add one 
        define_method "add_#{LINEAGE_NAME[parent]}_grand#{grandparent}" do |relative|
          raise IncompatibleRelationshipException, "#{self} can't be grand#{grandparent} of itself" if relative == self
          raise_if_gap_on(parent)
          send(parent).send("add_#{grandparent}",relative)
        end
        # remove one
        define_method "remove_#{LINEAGE_NAME[parent]}_grand#{grandparent}" do
          raise_if_gap_on(parent)
          send(parent).send("remove_#{grandparent}")
        end
      end
    end

    [:father, :mother].each do |parent|
      # add two by lineage
      define_method "add_#{LINEAGE_NAME[parent]}_grandparents" do |grandfather,grandmother|
        raise_if_gap_on(parent)
        send(parent).send("add_parents",grandfather,grandmother)
      end
      # remove two by lineage
      define_method "remove_#{LINEAGE_NAME[parent]}_grandparents" do
        raise_if_gap_on(parent)
        send(parent).send("remove_parents")
      end
    end

    # add all
    def add_grandparents(pgf,pgm,mgf,mgm)
      transaction do
        add_paternal_grandparents(pgf,pgm)
        add_maternal_grandparents(mgf,mgm)
      end
    end

    # remove all
    def remove_grandparents
      transaction do
        remove_paternal_grandparents
        remove_maternal_grandparents
      end
    end


    ## siblings
    def add_siblings(*args)
      options = args.extract_options!
      raise OptionException, "Can't specify father and mother at the same time: sibling should have at least one common parent" if (options[:father] and options[:mother])
      raise LineageGapException, "Can't add siblings if both parents are nil" unless father and mother
      raise IncompatibleRelationshipException, "Can't add an ancestor as sibling" unless (ancestors.to_a & args).empty?
      transaction do
        args.each do |sib|
          sib.add_father(options[:father] || self.father)
          sib.add_mother(options[:mother] || self.mother)
        end
      end
    end

    def remove_siblings
      
    end

    # offspring
    def add_offspring(*args)
      options = args.extract_options!
      
      raise_if_sex_undefined

      transaction do
        args.each do |child|
          case sex
          when sex_male_value
            child.add_father(self)
            child.add_mother(options[:with]) if options[:with]
          when sex_female_value
            child.add_father(options[:with]) if options[:with]
            child.add_mother(self)
          end
        end
      end
    end

    def remove_offspring(options = {})
      
      raise_if_sex_undefined

      children = offspring(options)
      transaction do
        children.each do |child|
          if options[:with] and (options[:affect_with] == true)
            child.remove_parents
          else
            case sex
            when sex_male_value
              child.remove_father
            when sex_female_value
              child.remove_mother
            end  
          end
        end
      end
      children.empty? ? false : true
    end

    ##################################################################
    ## query methods
    ##################################################################
    
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
        define_method "#{LINEAGE_NAME[parent]}_grand#{grandparent}" do
          send(parent) && send(parent).send(grandparent)
        end

      end

      # get two by lineage
      define_method "#{LINEAGE_NAME[parent]}_grandparents" do
        (send(parent) && send(parent).parents) || []
      end

    end

    # get all
    def grandparents
      result = []
      [:father, :mother].each do |parent|
        [:father, :mother].each do |grandparent|
          result << send("#{LINEAGE_NAME[parent]}_grand#{grandparent}")
        end
      end
      result.compact! if result.all?{|gp| gp.nil? }
      result
    end

    def offspring(options = {})

      if spouse = options[:with]
        raise WrongSexException, "Something wrong with spouse #{spouse} gender." if spouse.sex == sex 
      end
      case sex
      when sex_male_value
        self.class.find_all_by_father_id(id, :conditions => (["mother_id == ?", spouse.id] if spouse) )
      when sex_female_value
        self.class.find_all_by_mother_id(id, :conditions => (["father_id == ?", spouse.id] if spouse) )
      end
    end

    def siblings
      if father or mother
        (father.try(:offspring).to_a & mother.try(:offspring).to_a) - [self]
      else
        []
      end
    end

    def half_siblings
      if father or mother
        (father.try(:offspring).to_a | mother.try(:offspring).to_a) - [self] - siblings
      else
        []
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

    ##################################################################
    ## checking methods
    ##################################################################

    def raise_if_gap_on(relative)
      raise LineageGapException, "#{self} doesn't have #{relative}" unless send(relative)
    end

    def raise_if_sex_undefined
      raise WrongSexException, "Can't proceed if sex undefined for #{self}" unless is_male? or is_female?
    end

    module ClassMethods
    end

  end
end