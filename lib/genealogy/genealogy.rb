module Genealogy

  def has_parents options = {}

    attr_accessor :father_id, :mother_id

    belongs_to :father, class_name: 'SimplestIndividual', foreign_key: "father_id"
    belongs_to :mother, class_name: 'SimplestIndividual', foreign_key: "mother_id"

    # Include instance methods and class methods
    include Genealogy::Methods

  end
  
end