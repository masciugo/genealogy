module Genealogy
  # Module IneligibleMethods provides methods to run genealogy queries to retrive groups of individuals who cannot be relatives according to provided role.
  # It's included by the genealogy enabled AR model
  module IneligibleMethods
    extend ActiveSupport::Concern

    include Constants

    # @!macro [attach] generate
    #   @method ineligible_$1s
    #   list of individual who cannot be $1 according to the ineligibility level in use.
    #   At pedigree level it returns theirself, descendants and all individuals with unexpected sex.
    #   At pedigree and dates level it also includes all individuals who were not fertile during receiver's birth date range.
    #   @return [Array,NilClass] Return nil if $1 already assigned
    def self.generate_method_ineligibles_parent(parent)
      define_method "ineligible_#{parent}s" do
        unless self.send(parent) 
          ineligibles = []
          ineligibles |= descendants | [self] | gclass.send("#{OPPOSITESEX[PARENT2SEX[parent]]}s") if gclass.ineligibility_level >= PEDIGREE
          if gclass.ineligibility_level >= PEDIGREE_AND_DATES  and birth_range
            ineligibles |= (gclass.all - ineligibles).find_all do |indiv|
              !indiv.can_procreate_during?(birth_range)
            end
          end
          ineligibles
        end
      end
    end
    generate_method_ineligibles_parent(:father)
    generate_method_ineligibles_parent(:mother)


    # @!macro [attach] generate
    #   @method ineligible_$1_grand$2(grandparent)
    #   list of individual who cannot be $1 grand$2 according to the ineligibility level in use.
    #   At pedigree level it returns theirself, their $1 parent, descendants, full siblings, $1 half siblings and all individuals with unexpected sex.
    #   At pedigree and dates level it also includes their $1 parent's ineligible $2s or, if that parent is unknown, all individuals who were not fertile during receiver's $1 parent birth date range.
    #   @return [Array,NilClass] Return nil if $1 grand$2 already assigned
    def self.generate_method_ineligible_grandparent(lineage,grandparent)
      relationship = "#{lineage}_grand#{grandparent}"
      define_method "ineligible_#{relationship}s" do
        unless send(relationship)
          parent = send(LINEAGE2PARENT[lineage])          
          ineligibles = []
          ineligibles |= [parent].compact | descendants | siblings | send("#{lineage}_half_siblings") | [self] | gclass.send("#{OPPOSITESEX[PARENT2SEX[grandparent]]}s") if gclass.ineligibility_level >= PEDIGREE
          if gclass.ineligibility_level >= PEDIGREE_AND_DATES              
            ineligibles |= if parent
              parent.send("ineligible_#{grandparent}s")
            else
              (gclass.all - ineligibles).find_all do |indiv|
                !indiv.can_procreate_during?(send("#{LINEAGE2PARENT[lineage]}_birth_range"))
              end
            end
          end
          ineligibles
        end
      end
    end
    
    generate_method_ineligible_grandparent(:paternal,:father)
    generate_method_ineligible_grandparent(:paternal,:mother)
    generate_method_ineligible_grandparent(:maternal,:father)
    generate_method_ineligible_grandparent(:maternal,:mother)

    # list of individual who cannot be children according to the ineligibility level in use. 
    # At pedigree level it returns theirself, ancestors, children, full siblings and all individuals that already have father (if male) or mother (if female).
    # At pedigree and dates level it also includes all individuals who was born outside receiver's fertility range.
    # @return [Array]
    def ineligible_children
      ineligibles = []
      ineligibles |= ancestors | children | siblings | [self] | gclass.all_with(SEX2PARENT[ssex]) if gclass.ineligibility_level >= PEDIGREE
      if gclass.ineligibility_level >= PEDIGREE_AND_DATES and fertility_range
        ineligibles |= (gclass.all - ineligibles).find_all{ |indiv| !can_procreate_during?(indiv.birth_range)}
      end
      ineligibles
    end

    # list of individual who cannot be children according to the ineligibility level in use. 
    # At pedigree level it returns theirself, full siblings, ancestors, descendants and all individuals with different father or mother.
    # At pedigree and dates level it also includes all individuals who cannot be siblings for age reasons. For each known parent, 
    # ineligible siblings are parent's ineligible children, otherwise it tries to estimate parent birth range. If it's possible ineligible siblings are all individuals whose life range overlaps parent birth range.
    # @return [Array]
    def ineligible_siblings
      ineligibles = []
      if gclass.ineligibility_level >= PEDIGREE
        ineligibles |= ancestors | descendants | siblings | [self]
        ineligibles |= (father ? gclass.all_with(:father).where("father_id != ?", father) : [])
        ineligibles |= (mother ? gclass.all_with(:mother).where("mother_id != ?", mother) : [])
      end
      if gclass.ineligibility_level >= PEDIGREE_AND_DATES 
        # if a parent is present ineligible siblings are parent's ineligible children, otherwise try to estimate parent birth range.
        # If it's possible ineligible siblings are all individuals whose life range overlaps parent birth range
        [:father,:mother].each do |parent|
          if p = send(parent)
            ineligibles |= p.ineligible_children
          elsif parent_fertility_range = send("#{parent}_fertility_range")
            remainings = gclass.all - ineligibles
            ineligibles |= remainings.find_all do |indiv|
              if ibr = indiv.birth_range
                !parent_fertility_range.overlaps? ibr
              else
                false
              end
            end
          end
        end
      else
      end
      ineligibles
    end

  end
end