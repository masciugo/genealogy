module Genealogy
  class LineageGapException < StandardError;  end
  class SexError < StandardError;  end
  class IncompatibleRelationshipException < StandardError
    def initialize(msg = "Trying to create an incompatible relationship")
      super(msg)
    end
  end
end