class << ActiveRecord::Base
  def has_parents options = {}
    attr_accessor :father_id, :mother_id

    belongs_to :father, class_name: 'SimplestIndividual', foreign_key: "father_id"
    belongs_to :mother, class_name: 'SimplestIndividual', foreign_key: "mother_id"

    # Include instance methods
    include Genealogy::InstanceMethods

    # Include dynamic class methods
    extend Genealogy::ClassMethods

  end
end