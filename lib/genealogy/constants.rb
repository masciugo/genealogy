module Genealogy
  module Constants
    # deafault options for has_parent method
    DEFAULTS = {
      column_names: {
        sex: 'sex',
        father_id: 'father_id',
        mother_id: 'mother_id',
        current_spouse_id: 'current_spouse_id',
        birth_date: 'birth_date',
        death_date: 'death_date'
      },
      perform_validation: true,
      ineligibility: :pedigree,
      current_spouse: false,
      sex_values: ['M','F'],
      limit_ages: {
        min_male_procreation_age: 12,
        max_male_procreation_age: 75,
        min_female_procreation_age: 9,
        max_female_procreation_age: 50,
        max_male_life_expectancy: 110,
        max_female_life_expectancy: 110
      }
    }

    PARENT2LINEAGE = ActiveSupport::HashWithIndifferentAccess.new({ father: :paternal, mother: :maternal })
    LINEAGE2PARENT = ActiveSupport::HashWithIndifferentAccess.new({ paternal: :father, maternal: :mother })
    PARENT2SEX = ActiveSupport::HashWithIndifferentAccess.new({ father: :male, mother: :female })
    SEX2PARENT = ActiveSupport::HashWithIndifferentAccess.new({ male: :father, female: :mother })
    OPPOSITESEX = ActiveSupport::HashWithIndifferentAccess.new({male: :female, female: :male})

    AKA = ActiveSupport::HashWithIndifferentAccess.new({
      father: "F",
      mother: "M",
      paternal_grandfather: "PGF", 
      paternal_grandmother: "PGM", 
      maternal_grandfather: "MGF", 
      maternal_grandmother: "MGM", 
      children: "C",
      siblings: "S", 
      half_siblings: "HS",
      paternal_half_siblings: "PHS",
      maternal_half_siblings: "MHS", 
      grandchildren: "GC", 
      uncles_and_aunts: "U&A", 
      nieces_and_nephews: "N&N"
    })
  end
end