class SimplestIndividual < ActiveRecord::Base
  
  attr_accessible :name

  has_parents

end

