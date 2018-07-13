module Genealogy
  # Module IneligibleMethods provides methods to run genealogy queries to retrive groups of individuals who cannot be relatives according to provided role.
  # It's included by the genealogy enabled AR model
  module IneligibleMethods
    extend ActiveSupport::Concern

    include Constants

    # @!macro [attach] generate_method_ineligibles_parent_with_docs
    #   @method ineligible_$1s
    #   list of individual who cannot be $1 according to the ineligibility level in use.
    #   At `:pedigree` level it returns `self` along with their descendants and all $2s.
    #   At `:pedigree_and_dates` level it also includes all individuals who were not fertile during `self`'s estimated birth period.
    #   @return [Array, NilClass] Return nil if $1 already assigned
    def self.generate_method_ineligibles_parent_with_docs(parent_role,unexpected_sex)
      define_method "ineligible_#{parent_role}s" do
        unless self.send(parent_role)
          ineligibles = []
          ineligibles |= descendants | [self] | gclass.send("#{unexpected_sex}s") if gclass.ineligibility_level >= PEDIGREE
          if gclass.ineligibility_level >= PEDIGREE_AND_DATES  and birth_range
            ineligibles |= (gclass.all - ineligibles).find_all do |indiv|
              !indiv.can_procreate_during?(birth_range)
            end
          end
          ineligibles
        end
      end
    end
    generate_method_ineligibles_parent_with_docs(:father, :female)
    generate_method_ineligibles_parent_with_docs(:mother, :male)


    # @!macro [attach] generate_method_ineligible_grandparent_with_docs
    #   @method ineligible_$1_grand$3s
    #   list of individual who cannot be $1 grand$3 according to the ineligibility level in use. If `self`'s $2 is known, it returns $2's ineligible $3s.
    #   Otherwise, at `:pedigree` level it returns `self` along with descendants, full siblings and all $4s.
    #   At `:pedigree_and_dates` level it also includes all individuals who were not fertile during `self`'s $2 estimated birth period.
    #   @return [Array, NilClass] Return nil if $1 grand$3 already assigned
    def self.generate_method_ineligible_grandparent_with_docs(lineage,parent_role,grandparent2parent_role,unexpected_sex)
      relationship = "#{lineage}_grand#{grandparent2parent_role}"
      define_method "ineligible_#{relationship}s" do
        unless send(relationship)
          ineligibles = []
          if parent = send(parent_role)
            ineligibles |= parent.send("ineligible_#{grandparent2parent_role}s")
          elsif gclass.ineligibility_level >= PEDIGREE
            ineligibles |= descendants | siblings | [self] | gclass.send("#{unexpected_sex}s")
            if gclass.ineligibility_level >= PEDIGREE_AND_DATES
              ineligibles |= (gclass.all - ineligibles).find_all do |indiv|
                !indiv.can_procreate_during?(send("#{parent_role}_birth_range"))
              end
            end
          end
          ineligibles
        end
      end
    end

    generate_method_ineligible_grandparent_with_docs(:paternal,:father,:father, :female)
    generate_method_ineligible_grandparent_with_docs(:paternal,:father,:mother, :male)
    generate_method_ineligible_grandparent_with_docs(:maternal,:mother,:father, :female)
    generate_method_ineligible_grandparent_with_docs(:maternal,:mother,:mother, :male)

    # list of individual who cannot be children according to the ineligibility level in use.
    # At `:pedigree` level it returns `self` along with their ancestors, children, full siblings and all individuals that already have father (if male) or mother (if female).
    # At `:pedigree_and_dates` level it also includes all individuals who was born outside `self`'s fertility range, if estimable.
    # @return [Array]
    def ineligible_children
      ineligibles = []
      ineligibles |= ancestors | children | siblings | [self] | gclass.all_with(SEX2PARENT[ssex]) if gclass.ineligibility_level >= PEDIGREE
      if gclass.ineligibility_level >= PEDIGREE_AND_DATES and fertility_range
        ineligibles |= (gclass.all - ineligibles).find_all{ |indiv| !can_procreate_during?(indiv.birth_range)}
      end
      ineligibles
    end

    # list of individual who cannot be siblings according to the ineligibility level in use.
    # At `:pedigree` level it returns `self` along with their full siblings, ancestors, descendants and all individuals with different father or mother.
    # At `:pedigree_and_dates` level it also includes all individuals who cannot be siblings for age reasons. For each parent, if it is known
    # it includes parent's ineligible children, otherwise it tries to estimate parent's fertility period: if it's possible it includes all individuals whose estimated birth period doesn't overlap parent's fertility period.
    # @return [Array]
    def ineligible_siblings
      ineligibles = []
      if gclass.ineligibility_level >= PEDIGREE
        ineligibles |= ancestors | descendants | siblings | [self]
        ineligibles |= (father ? gclass.all_with(:father).where("father_id != ?", father) : [])
        ineligibles |= (mother ? gclass.all_with(:mother).where("mother_id != ?", mother) : [])
      end
      if gclass.ineligibility_level >= PEDIGREE_AND_DATES
        [:father,:mother].each do |parent|
          if p = send(parent)
            # if a parent is present ineligible siblings are parent's ineligible children
            ineligibles |= p.ineligible_children
          elsif parent_fertility_range = send("#{parent}_fertility_range")
            # if it's possible to estimate parent's fertility period
            remainings = gclass.all - ineligibles
            # includes all individuals whose estimated birth period doesn't overlap parent's fertility period
            ineligibles |= remainings.find_all do |indiv|
              if ibr = indiv.birth_range
                !parent_fertility_range.overlaps? ibr
              else
                false
              end
            end
          end
        end
      end
      ineligibles
    end

    # @!macro [attach] generate_method_ineligibles_half_siblings_with_docs
    #   @method ineligible_$1_half_siblings
    #   list of individual who cannot be $1 half_sibling according to the ineligibility level in use.
    #   At `:pedigree` level it returns `self` along with siblings, other lineage halfsiblngs and all individuals with differnt $2
    #   At `:pedigree_and_dates` level it also includes all individuals who cannot be siblings for age reasons. If $2 is known it includes $2's ineligible children,
    #   otherwise it tries to estimate $2's fertility period: if it's possible it includes all individuals whose estimated birth period doesn't overlap $2's fertility period.
    #   @return [Array]
    def self.generate_method_ineligibles_half_siblings_with_docs(lineage,parent_role)
      define_method "ineligible_#{lineage}_half_siblings" do
        ineligibles = []
        parent = LINEAGE2PARENT[lineage]
        p = send(parent)
        if gclass.ineligibility_level >= PEDIGREE
          ineligibles |= siblings | [self,p]
          ineligibles |= send("#{OPPOSITELINEAGE[lineage]}_half_siblings") # other lineage half siblings would become full siblings so they cannot be current lineage half sibling
          ineligibles |= gclass.all_with(parent).where("#{parent}_id != ?", p) if p
        end
        if gclass.ineligibility_level >= PEDIGREE_AND_DATES
          if p
            # if a parent is present ineligible siblings are parent's ineligible children
            ineligibles |= p.ineligible_children
          elsif parent_fertility_range = send("#{parent}_fertility_range")
            # if it's possible to estimate parent's fertility period
            remainings = gclass.all - ineligibles
            # includes all individuals whose estimated birth period doesn't overlap parent's fertility period
            ineligibles |= remainings.find_all do |indiv|
              if ibr = indiv.birth_range
                !parent_fertility_range.overlaps? ibr
              else
                false
              end
            end
          end
        end
        ineligibles

      end
    end
    generate_method_ineligibles_half_siblings_with_docs(:paternal, :father)
    generate_method_ineligibles_half_siblings_with_docs(:maternal, :mother)

  end
end
