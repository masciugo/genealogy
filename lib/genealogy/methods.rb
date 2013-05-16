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
      
      raise LineageGapException, "#{self} doesn't have #{parent}" unless parent
      
      [:father, :mother].each do |grandparent|

        # add
        define_method "add_#{LINEAGE_NAME[parent]}_grand#{grandparent}" do |relative|
          raise IncompatibleRelationshipException, "#{self} can't be grand#{grandparent} of itself" if relative == self
          send(parent).send("add_#{grandparent}",relative)
        end

        # remove
        define_method "remove_#{LINEAGE_NAME[parent]}_grand#{grandparent}" do
          send(parent).send("remove_#{grandparent}")
        end

      end
    end

    # add all
    def add_grandparents(pgf,pgm,mgf,mgm)
      transaction do
        father.add_parents(pgf,pgm)
        mother.add_parents(mgf,mgm)
      end
    end

    # remove all
    def remove_grandparents
      transaction do
        father.remove_parents
        mother.remove_parents
      end
    end

    LINEAGE_NAME.each do |parent,lineage|
      define_method "add_#{lineage}_grandparents" do |grandfather,grandmother|
        raise LineageGapException, "#{self} doesn't have #{parent}" unless send(parent)
        send(parent).send("add_parents",grandfather,grandmother)
      end

      define_method "remove_#{lineage}_grandparents" do
        raise LineageGapException, "#{self} doesn't have #{parent}" unless send(parent)
        send(parent).send("remove_parents")
      end

    end


    ## add siblings
    # no bang version
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

    # offspring
    # no bang version
    def add_offspring(*args)
      options = args.extract_options!
      raise OptionException, "Can't specify father if reciever is male" if options[:father] and is_male?
      raise OptionException, "Can't specify mother if reciever is female" if options[:mother] and is_female?
      
      raise WrongSexException, "Can't add offspring: undefined sex for #{self}" unless is_male? or is_female?
      transaction do
        args.each do |child|
          case sex
          when sex_male_value
            child.add_father(self)
            child.add_mother(options[:mother]) if options[:mother]
          when sex_female_value
            child.add_father(options[:father]) if options[:father]
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
        []
      end
    end

    # grandparents
    [:father, :mother].each do |parent|

      raise LineageGapException, "#{self} doesn't have #{parent}" unless parent
      
      [:father, :mother].each do |grandparent|

        define_method "#{LINEAGE_NAME[parent]}_grand#{grandparent}" do
          send(parent).send(grandparent)
        end

      end

      define_method "#{LINEAGE_NAME[parent]}_grandparents" do
        send(parent).parents
      end

    end

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