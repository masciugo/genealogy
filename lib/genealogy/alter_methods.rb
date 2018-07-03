module Genealogy
  # Module AlterMethods provides methods to alter genealogy. It's included by the genealogy enabled AR model
  module AlterMethods
    extend ActiveSupport::Concern

    include Constants

    # @!macro [attach] generate
    #   @method add_$1(parent)
    #   Add $1
    #   @param [Object] parent
    #   @raise [Exception] if perform validation is enabled and self is invalid
    #   @return [Boolean]
    def self.generate_method_add_parent(parent)
      define_method "add_#{parent}" do |relative|
        check_incompatible_relationship(parent,relative)
        if gclass.perform_validation_enabled
          self.send("#{parent}=",relative)
          save!
        else
          self.update_attribute(parent,relative)
        end
      end
    end
    generate_method_add_parent(:father)
    generate_method_add_parent(:mother)

    # @!macro [attach] generate
    #   @method remove_$1
    #   remove $1. Foreign_key set to nil
    #   @raise [Exception] if perform validation is enabled and self is invalid
    #   @return [Boolean]
    def self.generate_method_remove_parent(parent)
      define_method "remove_#{parent}" do
        if gclass.perform_validation_enabled
          self.send("#{parent}=",nil)
          save!
        else
          self.update_attribute(parent,nil)
        end
      end
    end
    generate_method_remove_parent(:father)
    generate_method_remove_parent(:mother)

    # add both parents calling #add_father and #add_mother in a transaction
    # @param [Object] father
    # @param [Object] mother
    # @see #add_father
    # @see #add_mother
    # @return [Boolean]
    def add_parents(father,mother)
      transaction do
        add_father(father)
        add_mother(mother)
      end
    end

    # remove both parents calling #remove_father and #remove_mother in a transaction
    # @see #remove_father
    # @see #remove_mother
    # @return [Boolean]
    def remove_parents
      transaction do
        remove_father
        remove_mother
      end
    end

    # @!macro [attach] generate
    #   @method add_$1_grand$2(grandparent)
    #   Add $1 grand$2
    #   @param [Object] gp grandparent
    #   @raise [Exception] if perform validation is enabled and self is invalid
    #   @return [Boolean]
    def self.generate_method_add_grandparent(lineage,grandparent)
      relationship = "#{lineage}_grand#{grandparent}"
      define_method "add_#{relationship}" do |gp|
        parent = LINEAGE2PARENT[lineage]
        raise_if_gap_on(parent)
        check_incompatible_relationship(relationship,gp)
        send(parent).send("add_#{grandparent}",gp)
      end
    end
    generate_method_add_grandparent(:paternal,:father)
    generate_method_add_grandparent(:paternal,:mother)
    generate_method_add_grandparent(:maternal,:father)
    generate_method_add_grandparent(:maternal,:mother)

    # @!macro [attach] generate
    #   @method remove_$1_grand$2
    #   remove $1 grand$2
    #   @raise [Exception] if perform validation is enabled and self is invalid
    #   @return [Boolean]
    def self.generate_method_remove_grandparent(lineage,grandparent)
      relationship = "#{lineage}_grand#{grandparent}"
      define_method "remove_#{relationship}" do
        parent = LINEAGE2PARENT[lineage]
        raise_if_gap_on(parent)
        send(parent).send("remove_#{grandparent}")
      end
    end
    generate_method_remove_grandparent(:paternal,:father)
    generate_method_remove_grandparent(:paternal,:mother)
    generate_method_remove_grandparent(:maternal,:father)
    generate_method_remove_grandparent(:maternal,:mother)

    # @!macro [attach] generate
    #   @method add_$1_grandparents
    #   Add $1 grandparents
    #   @param [Object] gf grandfather
    #   @param [Object] gm grandmother
    #   @raise [Exception] if perform validation is enabled and self is invalid
    #   @return [Boolean]
    def self.generate_method_add_grandparents_by_lineage(lineage)
      relationship = "#{lineage}_grandparents"
      define_method "add_#{relationship}" do |gf,gm|
        parent = LINEAGE2PARENT[lineage]
        raise_if_gap_on(parent)
        send(parent).send("add_parents",gf,gm)
      end
    end
    generate_method_add_grandparents_by_lineage(:paternal)
    generate_method_add_grandparents_by_lineage(:maternal)

    # @!macro [attach] generate
    #   @method remove_$1_grandparents
    #   remove $1 grandparents
    #   @raise [Exception] if perform validation is enabled and self is invalid
    #   @return [Boolean]
    def self.generate_method_remove_grandparents_by_lineage(lineage)
      relationship = "#{lineage}_grandparents"
      define_method "remove_#{relationship}" do
        parent = LINEAGE2PARENT[lineage]
        raise_if_gap_on(parent)
        send(parent).send("remove_parents")
      end
    end
    generate_method_remove_grandparents_by_lineage(:paternal)
    generate_method_remove_grandparents_by_lineage(:maternal)


    # add all grandparents calling #add_paternal_grandparents and #add_maternal_grandparents in a transaction
    # @param [Object] pgf paternal grandfather
    # @param [Object] pgm paternal grandmother
    # @param [Object] mgf maternal grandfather
    # @param [Object] mgm maternal grandmother
    # @see #add_paternal_grandparents
    # @see #add_maternal_grandparents
    # @return [Boolean]
    def add_grandparents(pgf,pgm,mgf,mgm)
      transaction do
        add_paternal_grandparents(pgf,pgm)
        add_maternal_grandparents(mgf,mgm)
      end
    end

    # remove all grandparents calling #remove_paternal_grandparents and #remove_maternal_grandparents in a transaction
    # @see #remove_paternal_grandparents
    # @see #remove_maternal_grandparents
    # @return [Boolean]
   def remove_grandparents
      transaction do
        remove_paternal_grandparents
        remove_maternal_grandparents
      end
    end

    # add siblings by assigning same parents to individuals passed as arguments
    # @overload add_siblings(*siblings,options={})
    #   @param [Object] siblings list of siblings
    #   @param [Hash] options
    #   @option options [Symbol] half :father for paternal half siblings and :mother for maternal half siblings
    #   @option options [Object] spouse if specified, passed individual will be used as mother in case of half sibling
    # @return [Boolean]
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

    # @see #add_siblings
    def add_sibling(sibling,options={})
      add_siblings(sibling,options)
    end

    # @see #add_siblings
    def add_paternal_half_siblings(*args)
      options = args.extract_options!
      options[:half] = :father
      add_siblings(*args,options)
    end

    # @see #add_siblings
    def add_maternal_half_siblings(*args)
      options = args.extract_options!
      options[:half] = :mother
      add_siblings(*args,options)
    end

    alias :add_paternal_half_sibling :add_paternal_half_siblings
    alias :add_maternal_half_sibling :add_maternal_half_siblings

    # remove siblings by nullifying parents of passed individuals
    # @overload remove_siblings(*siblings,options={})
    #   @param [Object] siblings list of siblings
    #   @param [Hash] options
    #   @option options [Symbol] half :father for paternal half siblings and :mother for maternal half siblings
    #   @option options [Boolean] remove_other_parent if specified, passed individuals' mother will also be nullified
    # @return [Boolean] true if at least one sibling was affected, false otherwise
    def remove_siblings(*args)
      options = args.extract_options!
      raise ArgumentError.new("Unknown option value: half: #{options[:half]}.") if (options[:half] and ![:father,:mother].include?(options[:half]))
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
            sib.remove_mother if options[:remove_other_parent] == true
          when :mother
            sib.remove_father if options[:remove_other_parent] == true
            sib.remove_mother
          when nil
            sib.remove_parents
          end
        end
      end
      !resulting_indivs.empty? #returned value must be true if self has at least a siblings to affect
    end

    # @see #remove_siblings
    def remove_sibling(sib,options={})
      remove_siblings(sib,options)
    end

    # @see #remove_siblings
    def remove_paternal_half_siblings(*args)
      options = args.extract_options!
      options[:half] = :father
      remove_siblings(*args,options)
    end

    # @see #remove_siblings
    def remove_maternal_half_siblings(*args)
      options = args.extract_options!
      options[:half] = :mother
      remove_siblings(*args,options)
    end

    alias :remove_paternal_half_sibling :remove_paternal_half_siblings
    alias :remove_maternal_half_sibling :remove_maternal_half_siblings


    # add children by assigning self as parent
    # @overload add_children(*children,options={})
    #   @param [Object] children list of children
    #   @param [Hash] options
    #   @option options [Object] spouse if specified, children will have that spouse
    # @return [Boolean]
    def add_children(*args)
      options = args.extract_options!
      raise_if_sex_undefined
      check_incompatible_relationship(:children, *args)
      transaction do
        args.inject(true) do |res,child|
          res &= case sex_before_type_cast
          when gclass.sex_male_value
            child.add_mother(options[:spouse]) if options[:spouse]
            child.add_father(self)
          when gclass.sex_female_value
            child.add_father(options[:spouse]) if options[:spouse]
            child.add_mother(self)
          else
            raise SexError, "Sex value not valid for #{self}"
          end
        end
      end
    end

    # see #add_children
    def add_child(child,options={})
      add_children(child,options)
    end

    # remove children by nullifying the parent corresponding to self
    # @overload remove_children(*children,options={})
    #   @param [Object] children list of children
    #   @param [Hash] options
    #   @option options [Boolean] remove_other_parent if specified, passed individuals' mother will also be nullified
    # @return [Boolean] true if at least one child was affected, false otherwise
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
          if options[:remove_other_parent] == true
            child.remove_parents
          else
            case sex_before_type_cast
            when gclass.sex_male_value
              child.remove_father
            when gclass.sex_female_value
              child.remove_mother
            else
              raise SexError, "Sex value not valid for #{self}"
            end
          end
        end
      end
      !resulting_indivs.empty? #returned value must be true if self has at least a siblings to affect
    end

    # see #remove_children
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

  end
end

