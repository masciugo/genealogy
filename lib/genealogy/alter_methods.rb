module Genealogy
  module AlterMethods
    extend ActiveSupport::Concern

    # parents 
    [:father, :mother].each do |parent|

      # add method
      define_method "add_#{parent}" do |relative|
        check_incompatible_relationship(parent,relative) unless relative.nil?
        if perform_validation
          self.send("#{parent}=",relative)
          save!
        else
          self.update_attribute(parent,relative)
        end
      end

      # remove method
      define_method "remove_#{parent}" do
        if perform_validation
          self.send("#{parent}=",nil)
          save!
        else
          self.update_attribute(parent,nil)
        end
      end

    end

    def add_parents(father,mother)
      transaction do
        add_father(father)
        add_mother(mother)
      end
    end

    def remove_parents
      transaction do
        remove_father
        remove_mother
      end
    end

    # grandparents
    [:father, :mother].each do |parent|
      [:father, :mother].each do |grandparent|
        relationship = "#{Genealogy::PARENT2LINEAGE[parent]}_grand#{grandparent}"
        # add one 
        define_method "add_#{relationship}" do |relative|
          raise_if_gap_on(parent)
          check_incompatible_relationship(relationship,relative)
          send(parent).send("add_#{grandparent}",relative)
        end
        # remove one
        define_method "remove_#{relationship}" do
          raise_if_gap_on(parent)
          send(parent).send("remove_#{grandparent}")
        end
      end
    end

    [:father, :mother].each do |parent|
      # add two by lineage
      define_method "add_#{Genealogy::PARENT2LINEAGE[parent]}_grandparents" do |grandfather,grandmother|
        raise_if_gap_on(parent)
        send(parent).send("add_parents",grandfather,grandmother)
      end
      # remove two by lineage
      define_method "remove_#{Genealogy::PARENT2LINEAGE[parent]}_grandparents" do
        raise_if_gap_on(parent)
        send(parent).send("remove_parents")
      end
    end

    def add_grandparents(pgf,pgm,mgf,mgm)
      transaction do
        add_paternal_grandparents(pgf,pgm)
        add_maternal_grandparents(mgf,mgm)
      end
    end

    def remove_grandparents
      transaction do
        remove_paternal_grandparents
        remove_maternal_grandparents
      end
    end

    ## siblings
    def add_siblings(*args)
      options = args.extract_options!
      check_incompatible_relationship(:sibling, *args)
      transaction do
        args.inject(true) do |res,sib|
          res &= case options[:half]
          when :father
            raise LineageGapException, "Can't add paternal halfsiblings without a father" unless father
            sib.add_mother(options[:spouse]) if options[:spouse]
            sib.add_father(father)
          when :mother
            raise LineageGapException, "Can't add maternal halfsiblings without a mother" unless mother
            sib.add_father(options[:spouse]) if options[:spouse]
            sib.add_mother(mother)
          when nil
            raise LineageGapException, "Can't add siblings without parents" unless father and mother
            sib.add_father(father)
            sib.add_mother(mother)
          else
            raise ArgumentError, "Admitted values for :half options are: :father, :mother or nil"
          end
        end
      end
    end

    def add_sibling(sib,options={})
      add_siblings(sib,options)
    end

    def remove_siblings(*args)
      options = args.extract_options!
      raise ArgumentError.new("Unknown option value: :half => #{options[:half]}.") if (options[:half] and ![:father,:mother].include?(options[:half]))
      resulting_indivs = if args.blank?
        siblings(options)
      else
        args & siblings(options)
      end
      transaction do
        resulting_indivs.each do |sib|
          case options[:half]
          when :father
            sib.remove_father
            sib.remove_mother if options[:affect_spouse] == true
          when :mother
            sib.remove_father if options[:affect_spouse] == true
            sib.remove_mother
          when nil
            sib.remove_parents
          end  
        end
      end
      !resulting_indivs.empty? #returned value must be true if self has at least a siblings to affect
    end

    def remove_sibling(sib,options={})
      remove_siblings(sib,options)
    end

    [:father, :mother].each do |parent|

      # add paternal/maternal half_siblings
      define_method "add_#{Genealogy::PARENT2LINEAGE[parent]}_half_siblings" do | *args |
        options = args.extract_options!
        options[:half] = parent
        args << options
        send("add_siblings",*args)
      end

      # add paternal/maternal half_sibling
      define_method "add_#{Genealogy::PARENT2LINEAGE[parent]}_half_sibling" do | sib,options={} |
        options[:half] = parent
        send("add_sibling",sib,options)
      end

      # remove paternal/maternal half_siblings
      define_method "remove_#{Genealogy::PARENT2LINEAGE[parent]}_half_siblings" do | *args |
        options = args.extract_options!
        options[:half] = parent
        args << options
        send("remove_siblings",*args)
      end

      # remove paternal/maternal half_sibling
      define_method "remove_#{Genealogy::PARENT2LINEAGE[parent]}_half_sibling" do | sib,options={} |
        options[:half] = parent
        send("remove_sibling",sib,options)
      end
    end

    # children
    def add_children(*args)
      options = args.extract_options!
      raise_if_sex_undefined
      check_incompatible_relationship(:children, *args)
      transaction do
        args.inject(true) do |res,child|
          res &= case sex
          when sex_male_value
            child.add_mother(options[:spouse]) if options[:spouse]
            child.add_father(self)
          when sex_female_value
            child.add_father(options[:spouse]) if options[:spouse]
            child.add_mother(self)
          else 
            raise SexError, "Sex value not valid for #{self}"
          end
        end
      end
    end

    def add_child(child,options={})
      add_children(child,options)
    end

    def remove_children(*args)
      options = args.extract_options!

      raise_if_sex_undefined

      resulting_indivs = if args.blank?
        children(options)
      else
        args & children(options)
      end

      transaction do
        resulting_indivs.each do |child|
          if options[:affect_spouse] == true
            child.remove_parents
          else
            case sex
            when sex_male_value
              child.remove_father
            when sex_female_value
              child.remove_mother
            else 
              raise SexError, "Sex value not valid for #{self}"
            end  
          end
        end
      end
      !resulting_indivs.empty? #returned value must be true if self has at least a siblings to affect
    end

    def remove_child(child,options={})
      remove_children(child,options)
    end

    private

    def raise_if_gap_on(relative)
      raise LineageGapException, "#{self} doesn't have #{relative}" unless send(relative)
    end

    def raise_if_sex_undefined
      raise SexError, "Can't proceed if sex undefined for #{self}" unless is_male? or is_female?
    end

    def check_incompatible_relationship(*args)
      relationship = args.shift
      args.each do |relative|
        # puts "[#{__method__}]: #{arg} class: #{arg.class}, #{self} class: #{self.class}"
        raise ArgumentError, "Expected #{self.genealogy_class} object. Got #{relative.class}" unless relative.class.equal? self.genealogy_class
        # puts "[#{__method__}]: checking if #{relative} can be #{relationship} of #{self}"
        raise IncompatibleRelationshipException, "#{relative} can't be #{relationship} of #{self}" if self.send("ineligible_#{relationship.to_s.pluralize}").include? relative
      end
    end

  end
end

