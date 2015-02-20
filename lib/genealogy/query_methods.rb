module Genealogy
  # Module QueryMethods provides methods to run genealogy queries to retrive relatives by role. It's included by the genealogy enabled AR model
  module QueryMethods
    extend ActiveSupport::Concern

    include Constants

    # @return [2-elements Array] father and mother 
    def parents
      [father,mother]
    end

    def paternal_grandfather
      father && father.father
    end

    def paternal_grandmother
      father && father.mother
    end

    def maternal_grandfather
      mother && mother.father
    end

    def maternal_grandmother
      mother && mother.mother
    end

    # @return [2-elements Array] paternal_grandfather and paternal_grandmother 
    def paternal_grandparents
      father && father.parents
    end

    # @return [2-elements Array] maternal_grandfather and maternal_grandmother
    def maternal_grandparents
      mother && mother.parents
    end

    # @return [4-elements Array] paternal_grandfather, paternal_grandmother, maternal_grandfather, maternal_grandmother
    def grandparents
      [paternal_grandfather, paternal_grandmother, maternal_grandfather, maternal_grandmother]
    end

    # @return [8-elements Array] paternal_grandfather's father, paternal_grandmother's father, maternal_grandfather's father, maternal_grandmother's father, paternal_grandfather's mother, paternal_grandmother's mother, maternal_grandfather's mother, maternal_grandmother's mother
    def great_grandparents
      grandparents.inject([]){|memo, gp| memo += (gp.try(:parents) || [nil,nil]) }.flatten
    end

    # @param [Hash] options
    # @option options [Symbol] sex to filter result by sex: :male or :female. 
    # @option options [Object] spouse to filter children by spouse
    # @return [Array] children
    def children(options = {})
      if spouse = options[:spouse]
        raise SexError, "Problems while looking for #{self}'s children made with spouse #{spouse} who should not be a #{spouse.sex}." if spouse.sex == sex
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
      else
        raise SexError, "Sex value not valid for #{self}"
      end
      filter_by_sex(result,options[:sex])
    end

    # @return [Array] list of individuals with whom has had children
    def spouses
      parent_method = SEX2PARENT[OPPOSITESEX[sex_to_s.to_sym]]
      children.collect{|child| child.send(parent_method)}.uniq
    end

    # @param [Hash] options
    # @option options [Symbol] sex to filter result by sex: :male or :female. 
    # @option options [Symbol] half let you filter siblings. Possible values are:
    #   :father for paternal halfsiblings
    #   :mother for maternal halfsiblings
    #   :only for all halfsiblings
    #   :include for fullsiblings and halfsiblings
    # @return [Array] list of fullsiblings and/or halfsiblings
    def siblings(options = {})
      result = case options[:half]
      when nil # only full siblings
        unless parents.include?(nil)
          father.try(:children, :spouse => mother ).to_a
        else
          []
        end
      when :father # common father
        father.try(:children, options.keys.include?(:spouse) ? {:spouse => options[:spouse]} : {}).to_a - mother.try(:children).to_a
      when :mother # common mother
        mother.try(:children, options.keys.include?(:spouse) ? {:spouse => options[:spouse]} : {}).to_a - father.try(:children).to_a
      when :only # only half siblings
        siblings(:half => :include) - siblings
      when :include # including half siblings
        father.try(:children).to_a + mother.try(:children).to_a
      else
        raise ArgumentError, "Admitted values for :half options are: :father, :mother, false, true or nil"
      end
      filter_by_sex(result.uniq - [self],options[:sex])
    end

    # siblings with option :half => :only
    # @see #siblings 
    def half_siblings(options = {})
      siblings(options.merge(:half => :only))
    end

    # siblings with option :half => :father
    # @see #siblings
    def paternal_half_siblings(options = {})
      siblings(options.merge(:half => :father))
    end

    # siblings with option :half => :mother
    # @see #siblings
    def maternal_half_siblings(options = {})
      siblings(options.merge(:half => :mother))
    end

    # get list of known ancestrors iterateing over parents
    # @param [Hash] options
    # @option options [Symbol] sex to filter result by sex: :male or :female. 
    # @return [Array] list of ancestors
    def ancestors(options = {})
      result = []
      remaining = parents.compact
      until remaining.empty?
        result << remaining.shift
        remaining += result.last.parents.compact
      end
      filter_by_sex(result.uniq,options[:sex])
    end


    # get list of known descendants iterateing over children ...
    # @param [Hash] options
    # @option options [Symbol] sex to filter result by sex: :male or :female. 
    # @return [Array] list of descendants
    def descendants(options = {})
      result = []
      remaining = children.to_a.compact
      until remaining.empty?
        result << remaining.shift
        remaining += result.last.children.to_a.compact
        # break if (remaining - result).empty? can be necessary in case of loop. Idem for ancestors method
      end
      filter_by_sex(result.uniq,options[:sex])
    end

    # @return [Array] list of grandchildren
    # @param [Hash] options
    # @option options [Symbol] sex to filter result by sex: :male or :female. 
    def grandchildren(options = {})
      result = children.inject([]){|memo,child| memo |= child.children}
      filter_by_sex(result,options[:sex])
    end

    # @return [Array] list of grat-grandchildren
    # @param [Hash] options
    # @option options [Symbol] sex to filter result by sex: :male or :female. 
    def great_grandchildren(options = {})
      result = grandchildren.compact.inject([]){|memo,grandchild| memo |= grandchild.children}
      filter_by_sex(result,options[:sex])
    end
    
    # list of uncles and aunts iterating through parents' siblings
    # @param [Hash] options
    # @option options [Symbol] lineage to filter by lineage: :paternal or :maternal
    # @option options [Symbol] sex to filter by sex: :male or :female. In few word to get ancles or aunts
    # @option options [Symbol] half to filter by half siblings (see #siblings)
    # @return [Array] list of uncles and aunts
    def uncles_and_aunts(options={})
      relation = case options[:lineage]
      when :paternal
        [father]
      when :maternal
        [mother]
      else
        parents
      end
      result = relation.compact.inject([]){|memo,parent| memo |= parent.siblings(half: options[:half])}
      filter_by_sex(result,options[:sex])
    end

    # uncles_and_aunts with option sex: :male
    # @see #uncles_and_aunts
    def uncles(options = {})
      uncles_and_aunts(options.merge(sex: :male))
    end

    # uncles_and_aunts with option sex: :female
    # @see #uncles_and_aunts
    def aunts(options={})
      uncles_and_aunts(options.merge(sex: :female))
    end

    # uncles_and_aunts with options  sex: :male, lineage: :paternal
    # @see #uncles_and_aunts
    def paternal_uncles(options = {})
      uncles(options.merge(lineage: :paternal))
    end

    # uncles_and_aunts with options  sex: :male, lineage: :maternal
    # @see #uncles_and_aunts
    def maternal_uncles(options = {})
      uncles(options.merge(lineage: :maternal))
    end

    # uncles_and_aunts with options sex: :female, lineage: :paternal
    # @see #uncles_and_aunts
    def paternal_aunts(options = {})
      aunts(options.merge(lineage: :paternal))
    end

    # uncles_and_aunts with options sex: :female, lineage: :maternal
    # @see #uncles_and_aunts
    def maternal_aunts(options = {})
      aunts(options.merge(lineage: :maternal))
    end

    # @param [Hash] options
    # @option options [Symbol] lineage to filter uncles by lineage: :paternal or :maternal
    # @option options [Symbol] half to filter uncles (see #siblings)
    # @option options [Symbol] sex to filter cousins by sex: :male or :female. 
    # @return [Array] list of uncles and aunts' children
    def cousins(options = {})
      sex = options.delete(:sex)
      result = uncles_and_aunts(options).compact.inject([]){|memo,uncle| memo |= uncle.children}
      filter_by_sex(result,sex)
    end

    # @param [Hash] options
    # @option options [Symbol] half to filter siblings (see #siblings)
    # @option options [Symbol] sex to filter result by sex: :male or :female. 
    # @return [Array] list of nieces and nephews
    def nieces_and_nephews(options = {})
      sex = options.delete(:sex)
      result = siblings(options).inject([]){|memo,sib| memo |= sib.children}
      filter_by_sex(result,sex)
    end

    # nieces_and_nephews with option sex: :male
    # @see #nieces_and_nephews
    def nephews(options = {})
      nieces_and_nephews(options.merge({sex: :male}))
    end

    # nieces_and_nephews with option sex: :female
    # @see #nieces_and_nephews
    def nieces(options = {})
      nieces_and_nephews(options.merge({sex: :female}))
    end

    # family hash with roles as keys and individuals as values. Defaults roles are :father, :mother, :children, :siblings and current_spouse if enabled
    # @option options [Symbol] half to filter siblings (see #siblings)
    # @option options [Boolean] extended to include roles for grandparents, grandchildren, uncles, aunts, nieces, nephews and cousins
    # @return [Hash] family hash with roles as keys and individuals as values. 
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
          raise ArgumentError, "Admitted values for :half options are: :father, :mother, :include, nil"
      end
      roles += [:paternal_grandfather, :paternal_grandmother, :maternal_grandfather, :maternal_grandmother, :grandchildren, :uncles_and_aunts, :nieces_and_nephews, :cousins] if options[:extended] == true
      roles.inject({}){|res,role| res.merge!({role => self.send(role)})}
    end

    # family_hash with option extended: :true
    # @see #family_hash
    def extended_family_hash(options = {})
      family_hash(options.merge(:extended => true))
    end

    # family individuals
    # @return [Array]
    # @see #family_hash 
    def family(options = {})
      hash = family_hash(options)
      hash.keys.inject([]){|tot,k| tot << hash[k] }.compact.flatten
    end

    # family with option extended: :true
    # @see #family
    def extended_family(options = {})
      family(options.merge(:extended => true))
    end

    private

    def filter_by_sex(list,sex)
      case sex
      when :male
        list.select(&:is_male?)
      when :female
        list.select(&:is_female?)
      else
        list
      end

    end

    module ClassMethods
      # all male individuals
      # @return [ActiveRecord_Relation] 
      def males
        where(sex_column => sex_male_value)
      end
      # all female individuals
      # @return [ActiveRecord_Relation] 
      def females
        where(sex_column => sex_female_value)
      end
      # all individuals with parents
      # @return [ActiveRecord_Relation] 
      def indivs_with_parents
        where("#{father_id_column} IS NOT ? AND #{mother_id_column} IS NOT ?", nil,nil)
      end


    end

  end
end