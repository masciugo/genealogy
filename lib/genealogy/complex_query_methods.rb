module Genealogy
  module ComplexQueryMethods
    extend ActiveSupport::Concern
    include Constants

    module ClassMethods

      # Takes a splat argument of gclass objects and @return [ActiveRecord::Relation] of the first individual(s) to show up in the ancestors of the given people
      # It moves up one generation at a time for each individual, stopping when there is a shared ancestor id or when there are no more ancestors
      # If called on two full siblings, it will return both parents, as they appears in the same generation
      # If called on two half siblings, it will return only the shared parent
      # If one individual is the ancestor of the other, it will return that individual as the least common shared ancestors
      # If none are found, it will return an empty AR relation.
      def lowest_common_ancestors(*people)
        raise ArgumentError, "all inputs must be an instance of the #{gclass} class" if people.select{|record| !record.is_a?(gclass)}.length > 0

        parent_ids_temp = people.map{|person| [person.id]}
        parent_ids_store = parent_ids_temp.clone

        generation_count = 1

        while parent_ids_temp.select{|array_of_ids| array_of_ids.length > 0}.length > 0
          next_gen_ids = parent_ids_temp.map{|ids| gclass.where(id: ids).pluck(:father_id, :mother_id).flatten.compact}

          next_gen_ids.each_with_index do |ids, index|
            parent_ids_store[index] += ids
            parent_ids_temp[index]   = ids
          end

          if parent_ids_store.reduce(:&).length > 0
            return gclass.where(id: (parent_ids_store.reduce(:&)))
          else
            generation_count += 1
          end
        end
        gclass.where(id: nil)
      end
    end

    def lowest_common_ancestors(*people)
      people << self
      self.class.lowest_common_ancestors(*people)
    end

  end
end
