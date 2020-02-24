module Genealogy
  module Constants
    extend ActiveSupport::Concern

    included do |base|
      # deafault options for has_parent method
      base.const_set :DEFAULTS, {
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

      # ineligibility levels
      base.const_set :PEDIGREE, 1
      base.const_set :PEDIGREE_AND_DATES, 2
      base.const_set :OFF, 0

      base.const_set :PARENT2LINEAGE, ActiveSupport::HashWithIndifferentAccess.new({ father: :paternal, mother: :maternal })
      base.const_set :LINEAGE2PARENT, ActiveSupport::HashWithIndifferentAccess.new({ paternal: :father, maternal: :mother })
      base.const_set :OPPOSITELINEAGE, ActiveSupport::HashWithIndifferentAccess.new({ paternal: :maternal, maternal: :paternal })
      base.const_set :PARENT2SEX, ActiveSupport::HashWithIndifferentAccess.new({ father: :male, mother: :female })
      base.const_set :SEX2PARENT, ActiveSupport::HashWithIndifferentAccess.new({ male: :father, female: :mother })
      base.const_set :OPPOSITESEX, ActiveSupport::HashWithIndifferentAccess.new({male: :female, female: :male})

      base.const_set :AKA, ActiveSupport::HashWithIndifferentAccess.new({
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
end
