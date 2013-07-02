module Genealogy
  PARENT2LINEAGE = { :father => :paternal, :mother => :maternal }
  LINEAGE2PARENT = PARENT2LINEAGE.invert
  PARENT2SEX = { :father => :male, :mother => :female }
  SEX2PARENT = PARENT2SEX.invert
  OPPOSITESEX = {:male => :female, :female => :male}

  AKA = {
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
  }
end