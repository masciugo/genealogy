module Genealogy
  module ComplexQueryMethods
    extend ActiveSupport::Concern
    include Constants

    def least_common_ancestor(other_person)
      self_parent_ids = [self.id]
      other_parent_ids = [other_person.id]

      generation_count = 1

      self_ancestor_records = [self]
      other_ancestor_records = [other_person]

      while self_parent_ids.length > 0 || other_parent_ids.length > 0
        self_store = gclass.where(id: self_parent_ids)
        other_store = gclass.where(id: other_parent_ids)

        self_next_gen = self_store.flat_map(&:parents).compact
        other_next_gen = other_store.flat_map(&:parents).compact

        self_ancestor_records += self_next_gen
        other_ancestor_records += other_next_gen

        self_parent_ids = self_next_gen.compact.map(&:id)
        other_parent_ids = other_next_gen.compact.map(&:id)

        if (self_ancestor_records & other_ancestor_records).compact.length > 0
          return gclass.where(id: (self_ancestor_records & other_ancestor_records).map(&:id))
        else
          generation_count += 1
        end
      end
      gclass.where(id: nil)
    end

  end
end