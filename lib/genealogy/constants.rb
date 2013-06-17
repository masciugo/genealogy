module Genealogy
  PARENT2LINEAGE = { :father => :paternal, :mother => :maternal }
  LINEAGE2PARENT = PARENT2LINEAGE.invert
  PARENT2SEX = { :father => :male, :mother => :female }
  SEX2PARENT = PARENT2SEX.invert
end