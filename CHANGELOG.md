# Genealogy Changelog

## 2.0.0

### new features

* YARD docs

* 

### bug fixes

* cousins query method with options

* eligible siblings method now excludes descendants

* 

* 

* 

### backward incompatibilities

* add_father, add_mother and add_current_spouse methods not raising a SexError anymore. IncompatibleRelationshipException will be raised

* age query method removed 

* removed offspring* methods in favor of children* methods

* family* methods doesn't include receiver

* eligible methods removed in favor of ineligible ones 

* query methods that used to return Array with arbitrary lenght like #children or #ancestors now return ActiveRecord::Relation

* add/remove_paternal/maternal_half_siblings removed for sake of semplicity/manteinance. use add/remove_siblings with options

## 1.5.0



