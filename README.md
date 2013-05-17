# Genealogy

Genealogy is a ruby gem library which enhance ActiveRecord models with familiar relationships capabilities in order to build and query genealogies. If records of your model need to be linked and act as they were individuals of a family just add two parents column to its table (ie.: *father_id* and *mother_id*) and make your model to *:has_parents*. This macro will provide the two fundamental self-join associations, *father* and *mother*, whose everything depend on.  
Genealogy takes inspiration from the simple [linkage file format](http://www.helsinki.fi/~tsjuntun/autogscan/pedigreefile.html) which represent genealogies in terms of set of trios: *individual_id*, *father_id*, *mother_id*. Basically the only primitive familiar relationships are associations father and mother, all others like grandparents, siblings or offspring are derived. This means that all methods in charge of update the genealogy (adding/removing relatives) will end up to use the fundamental method add/remove_parent to the right records

## Installation

To apply Genealogy in its simplest form to any ActiveRecord model, follow these simple steps:  

1. Install   
    1. Add to Gemfile: gem ‘genealogy’   
    2. Install required gems: bundle install    

2. Add the foreign key parents columns to your table     
    1. Create migration: `rails g migration add_parents_to_[table] father_id:integer mother_id:integer`       
    2. Add index to migration    
    3. Migrate your database: `rake db:migrate`

3. Add `has_parents` to your model

## Usage

Instance methods are two kinds: *modifiers* and *queries*

### Modifiers methods

They change the genealogy updating one ore more target individuals. Here are some examples where target individual match with method's receiver:

* `george.add_father(peter)` will change george's father_id to peter.id
* `george.add_father(charlie)` will overwrite george's father_id
* `george.add_mother(gina)` 
* `george.add_parents(peter,gina)`
* `george.remove_father` will set to nel george's father_id 
* `george.remove_parents`

Not always the method's receiver is the instance that get updated:

* `george.add_paternal_grandmother(gina)` will change mother of george's father. No changes for george and gina

Even if it can seem weird try to see it as an intuitive shortcut to quickly build the genealogy.
Some methods can take a list of individuals:

* `george.add_grandparents(paul,gina,nick,mary)` will change both george's parents
* `george.add_grandparents(paul,nil,nick,mary)` you can skip unknown relatives

* `julian.add_siblings(gina,rita)` will change gina and rita's parents to the julian's ones

Half parent relationships are admitted

* `luke.add_offspring(julian)` 