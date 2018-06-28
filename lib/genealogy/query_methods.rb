module Genealogy
  # Module QueryMethods provides methods to run genealogy queries to retrive relatives by role. It's included by the genealogy enabled AR model
  module QueryMethods
    extend ActiveSupport::Concern

    include Constants

    # @return [2-elements Array] father and mother
    def parents
      [father,mother]
    end
    # @return [ActiveRecord, NilClass]
    def paternal_grandfather
      father && father.father
    end
    # @return [ActiveRecord, NilClass]
    def paternal_grandmother
      father && father.mother
    end
    # @return [ActiveRecord, NilClass]
    def maternal_grandfather
      mother && mother.father
    end
    # @return [ActiveRecord, NilClass]
    def maternal_grandmother
      mother && mother.mother
    end

    # @return [2-elements Array] paternal_grandfather and paternal_grandmother
    def paternal_grandparents
      (father && father.parents) || [nil,nil]
    end

    # @return [2-elements Array] maternal_grandfather and maternal_grandmother
    def maternal_grandparents
      (mother && mother.parents) || [nil,nil]
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
    # @option options [Object] spouse to filter children by spouse
    # @return [ActiveRecord::Relation] children
    def children(options = {})
      raise SexError, "Sex value not valid for #{self}. It's needed to look for children" unless gclass.sex_values.include? sex_before_type_cast
      result = gclass.where("#{SEX2PARENT[ssex]}_id" => self)
      if options.keys.include? :spouse
        check_indiv(spouse = options[:spouse],opposite_ssex)
        result = result.where("#{SEX2PARENT[opposite_ssex]}_id" => spouse ) if spouse
      end
      result
    end

    # @return [ActiveRecord::Relation] list of individuals with whom has had children
    def spouses
      gclass.where(id: children.pluck("#{SEX2PARENT[opposite_ssex]}_id".to_sym).compact.uniq)
    end

    # @param [Hash] options
    # @option options [Symbol] half let you filter siblings. Possible values are:
    #   :father for paternal halfsiblings
    #   :mother for maternal halfsiblings
    #   :only for all halfsiblings
    #   :include for fullsiblings and halfsiblings
    # @return [ActiveRecord::Relation] list of fullsiblings and/or halfsiblings
    def siblings(options = {})
      spouse = options[:spouse]
      result = gclass.where("id != ?",id)
      case options[:half]
      when nil # only full siblings
        result.all_with(:parents).where(father_id: father, mother_id: mother)
      when :father # common father
        result = result.all_with(:father).where(father_id: father)
        if spouse
          check_indiv(spouse, :female)
          result.where(mother_id: spouse)
        elsif mother
          result.where("mother_id != ? or mother_id is ?", mother_id, nil)
        else
          result
        end
      when :mother # common mother
        result = result.all_with(:mother).where(mother_id: mother)
        if spouse
          check_indiv(spouse, :male)
          result.where(father_id: spouse)
        elsif father
          result.where("father_id != ? or father_id is ?", father_id, nil)
        else
          result
        end
      when :only # only half siblings
        ids = siblings(half: :father).pluck(:id) | siblings(half: :mother).pluck(:id)
        result.where(id: ids)
      when :include # including half siblings
        result.where("father_id = ? or mother_id = ?", father_id, mother_id)
      else
        raise ArgumentError, "Admitted values for :half options are: :father, :mother, false, true or nil"
      end

    end

    # siblings with option half: :only
    # @see #siblings
    def half_siblings(options = {})
      siblings(options.merge(half: :only))
    end

    # siblings with option half: :father
    # @see #siblings
    def paternal_half_siblings(options = {})
      siblings(options.merge(half: :father))
    end

    # siblings with option half: :mother
    # @see #siblings
    def maternal_half_siblings(options = {})
      siblings(options.merge(half: :mother))
    end

    # get list of known ancestrors iterateing over parents
    # @param [Hash] options
    # @option options [Symbol] generations lets you limit how many generations will be included in the output.
    # @return [ActiveRecord::Relation] list of ancestors (limited by a number of generations if so indicated)
    def ancestors(options = {})
      ids = []
      if options[:generations]
        raise ArgumentError, ":generations option must be an Integer" unless options[:generations].is_a? Integer
        generation_count = 0
        generation_ids = parents.compact.map(&:id)
        while (generation_count < options[:generations]) && (generation_ids.length > 0)
          next_gen_ids = []
          ids += generation_ids
          until generation_ids.empty?
            ids.unshift(generation_ids.shift)
            next_gen_ids += gclass.find(ids.first).parents.compact.map(&:id)
          end
          generation_ids = next_gen_ids
          generation_count += 1
        end
      else
        remaining_ids = parents.compact.map(&:id)
        until remaining_ids.empty?
          ids << remaining_ids.shift
          remaining_ids += gclass.find(ids.last).parents.compact.map(&:id)
        end
      end
      gclass.where(id: ids)
    end


    # get list of known descendants iterateing over children ...
    # @param [Hash] options
    # @option options [Symbol] generations lets you limit how many generations will be included in the output.
    # @return [ActiveRecord::Relation] list of descendants (limited by a number of generations if so indicated)
    def descendants(options = {})
      ids = []
      if options[:generations]
        generation_count = 0
        generation_ids = children.map(&:id)
        while (generation_count < options[:generations]) && (generation_ids.length > 0)
          next_gen_ids = []
          ids += generation_ids
          until generation_ids.empty?
            ids.unshift(generation_ids.shift)
            next_gen_ids += gclass.find(ids.first).children.map(&:id)
          end
          generation_ids = next_gen_ids
          generation_count += 1
        end
      else
        remaining_ids = children.map(&:id)
        until remaining_ids.empty?
          ids << remaining_ids.shift
          remaining_ids += gclass.find(ids.last).children.pluck(:id)
          # break if (remaining_ids - ids).empty? can be necessary in case of loop. Idem for ancestors method
        end
      end
      gclass.where(id: ids)
    end

    # @return [ActiveRecord::Relation] list of grandchildren
    def grandchildren
      result = children.inject([]){|memo,child| memo |= child.children}
    end

    # @return [ActiveRecord::Relation] list of grat-grandchildren
    def great_grandchildren
      result = grandchildren.compact.inject([]){|memo,grandchild| memo |= grandchild.children}
    end

    # list of uncles and aunts iterating through parents' siblings
    # @param [Hash] options
    # @option options [Symbol] lineage to filter by lineage: :paternal or :maternal
    # @option options [Symbol] half to filter by half siblings (see #siblings)
    # @return [ActiveRecord::Relation] list of uncles and aunts
    def uncles_and_aunts(options={})
      relation = case options[:lineage]
      when :paternal
        [father]
      when :maternal
        [mother]
      else
        parents
      end
      ids = relation.compact.inject([]){|memo,parent| memo |= parent.siblings(half: options[:half]).pluck(:id)}
      gclass.where(id: ids)
    end

    # @see #uncles_and_aunts
    def uncles(options = {})
      uncles_and_aunts(options).males
    end

    # @see #uncles_and_aunts
    def aunts(options = {})
      uncles_and_aunts(options).females
    end

    # @see #uncles_and_aunts
    def paternal_uncles(options = {})
      uncles(options.merge(lineage: :paternal))
    end

    # @see #uncles_and_aunts
    def maternal_uncles(options = {})
      uncles(options.merge(lineage: :maternal))
    end

    # @see #uncles_and_aunts
    def paternal_aunts(options = {})
      aunts(options.merge(lineage: :paternal))
    end

    # @see #uncles_and_aunts
    def maternal_aunts(options = {})
      aunts(options.merge(lineage: :maternal))
    end

    # @param [Hash] options
    # @option options [Symbol] lineage to filter uncles by lineage: :paternal or :maternal
    # @option options [Symbol] half to filter uncles (see #siblings)
    # @return [ActiveRecord::Relation] list of uncles and aunts' children
    def cousins(options = {})
      ids = uncles_and_aunts(options).inject([]){|memo,uncle| memo |= uncle.children.pluck(:id)}
      gclass.where(id: ids)
    end

    # @param [Hash] options
    # @option options [Symbol] half to filter siblings (see #siblings)
    # @return [ActiveRecord::Relation] list of nieces and nephews
    def nieces_and_nephews(options = {})
      ids = siblings(options).inject([]){|memo,sib| memo |= sib.children.pluck(:id)}
      gclass.where(id: ids)
    end

    # @see #nieces_and_nephews
    def nephews(options = {})
      nieces_and_nephews.males
    end

    # @see #nieces_and_nephews
    def nieces(options = {})
      nieces_and_nephews.females
    end

    # family hash with roles as keys? :spouse and individuals as values. Defaults roles are :father, :mother, :children, :siblings and current_spouse if enabled
    # @option options [Symbol] half to filter siblings (see #siblings)
    # @option options [Boolean] extended to include roles for grandparents, grandchildren, uncles, aunts, nieces, nephews and cousins
    # @return [Hash] family hash with roles as keys? :spouse and individuals as values.
    def family_hash(options = {})
      roles = [:father, :mother, :children, :siblings]
      roles += [:current_spouse] if self.class.current_spouse_enabled
      roles += case options[:half]
        when nil
          []
        when :include
          [:half_siblings]
        when :include_separately
          [:paternal_half_siblings, :maternal_half_siblings]
        when :father
          [:paternal_half_siblings]
        when :mother
          [:maternal_half_siblings]
        else
          raise ArgumentError, "Admitted values for :half options are: :father, :mother, :include, :include_separately, nil"
      end
      roles += [:paternal_grandfather, :paternal_grandmother, :maternal_grandfather, :maternal_grandmother, :grandchildren, :uncles_and_aunts, :nieces_and_nephews, :cousins] if options[:extended] == true
      roles.inject({}){|res,role| res.merge!({role => self.send(role)})}
    end

    # family_hash with option extended: :true
    # @see #family_hash
    def extended_family_hash(options = {})
      family_hash(options.merge(extended: true))
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
      family(options.merge(extended: true))
    end

    private

    module ClassMethods
      # all male individuals
      # @return [ActiveRecord::Relation]
      def males
        where(sex: sex_male_value)
      end
      # all female individuals
      # @return [ActiveRecord::Relation]
      def females
        where(sex: sex_female_value)
      end
      # all individuals individuals having relative with specified role
      # @return [ActiveRecord, ActiveRecord::Relation]
      def all_with(role)
        case role
        when :father
          where('father_id is not ?',nil)
        when :mother
          where('mother_id is not ?',nil)
        when :parents
          where('father_id is not ? and mother_id is not ?',nil,nil)
        end
      end

    end

  end
end
