module Genealogy
  module ComplexQueryMethods
    extend ActiveSupport::Concern
    include Constants

    # @return [ActiveRecord::Relation] of the first individual(s) to show up in the ancestors of two given people. 
    # It moves up one generation at a time for each individual, stopping when there is a shared ancestor id or when there are no more ancestors
    # If called on two full siblings, it will return both parents, as they appears in the same generation
    # If called on two half siblings, it will return only the shared parent
    # If one individual is the ancestor of the other, it will return that individual as the least common shared ancestors
    # If none are found, it will return an empty AR relation.
    def least_common_ancestor(other_person)
      raise ArgumentError, "argument must be an instance of the #{gclass} class" unless other_person.is_a? gclass
      self_parent_ids = [self.id]
      other_parent_ids = [other_person.id]

      generation_count = 1

      self_ancestor_record_ids = [self.id]
      other_ancestor_record_ids = [other_person.id]

      while self_parent_ids.length > 0 || other_parent_ids.length > 0
        self_next_gen = gclass.where(id: self_parent_ids).pluck(:father_id, :mother_id).flatten.compact
        other_next_gen = gclass.where(id: other_parent_ids).pluck(:father_id, :mother_id).flatten.compact

        self_ancestor_record_ids += self_next_gen
        self_parent_ids = self_next_gen

        other_ancestor_record_ids += other_next_gen
        other_parent_ids = other_next_gen

        if (self_ancestor_record_ids & other_ancestor_record_ids).length > 0
          return gclass.where(id: (self_ancestor_record_ids & other_ancestor_record_ids))
        else
          generation_count += 1
        end
      end
      gclass.where(id: nil)
    end


  end
end
