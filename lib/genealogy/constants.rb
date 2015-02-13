module Genealogy
  PARENT2LINEAGE = ActiveSupport::HashWithIndifferentAccess.new({ :father => :paternal, :mother => :maternal })
  LINEAGE2PARENT = ActiveSupport::HashWithIndifferentAccess.new(PARENT2LINEAGE.invert)
  PARENT2SEX = ActiveSupport::HashWithIndifferentAccess.new({ :father => :male, :mother => :female })
  SEX2PARENT = ActiveSupport::HashWithIndifferentAccess.new(PARENT2SEX.invert)
  OPPOSITESEX = ActiveSupport::HashWithIndifferentAccess.new({:male => :female, :female => :male})

  AKA = ActiveSupport::HashWithIndifferentAccess.new({
    :father => "F",
    :mother => "M",
    :paternal_grandfather => "PGF", 
    :paternal_grandmother => "PGM", 
    :maternal_grandfather => "MGF", 
    :maternal_grandmother => "MGM", 
    :children => "C",
    :siblings => "S", 
    :half_siblings => "HS",
    :paternal_half_siblings => "PHS",
    :maternal_half_siblings => "MHS", 
    :grandchildren => "GC", 
    :uncles_and_aunts => "U&A", 
    :nieces_and_nephews => "N&N"
  })
end