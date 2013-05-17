# Genealogy (waiting for the first beta version...please wait few days!)

Genealogy is a ruby gem library which enhance ActiveRecord models with familiar relationships capabilities in order to build and query genealogies. If records of your model need to be linked and act as they were individuals of a family just add two parents column to its table (ie.: *father_id* and *mother_id*) and make your model to *:has_parents*. This macro will provide the two fundamental self-join associations, *father* and *mother*, whose everything depend on.  
Genealogy takes inspiration from the simple [linkage file format](http://www.helsinki.fi/~tsjuntun/autogscan/pedigreefile.html) which represent genealogies in terms of set of trios: *individual-id*, *father-id*, *mother-id*. Basically the only **primitive** familiar relationships are associations father and mother, all others like grandparents, siblings or offspring are **derived**. This means that all methods in charge of update the genealogy (adding/removing relatives) will end up to use the fundamental method `add/remove_parent` to the right records

## Installation

To apply Genealogy in its simplest form to any ActiveRecord model, follow these simple steps:  

1. Install   
    1. Add to Gemfile: gem ‘genealogy’   
    2. Install required gems: bundle install    

2. Add the foreign key parents columns to your table     
    1. Create migration: `rails g migration add_parents_to_[table] father_id:integer mother_id:integer`. A **sex column is also required**, add it if not exists.
    2. Add index separately and in combination to parents columns   
    3. Migrate your database: `rake db:migrate`

3. Add `has_parents` to your model

## Usage

Instance methods are two kinds: *modifiers* and *queries*

### Modifiers methods

They change the genealogy updating one ore more target individuals. These methods call internally *save!* so all validation and callbacks are regularly run. Here are some examples where target individual (the ones that are actually modified) correspond with method's receiver:

* `george.add_father(peter)` will change george's father_id to peter.id
* `george.add_father(charlie)` will overwrite george's father_id
* `george.add_mother(gina)` 
* `george.add_parents(peter,gina)` 

Not always the method's receiver is the instance that get updated:

* `george.add_paternal_grandmother(gina)` will change mother of george's father. No changes for george and gina. It can seem weird but think about it as an intuitive shortcut to quickly build the genealogy as a whole entity.

* `george.add_paternal_grandparents(julius,marta)` will change parents of george's father like the *add_parents* method does.

Some methods can take a list of individuals:

* `george.add_grandparents(paul,gina,nick,mary)` will change both george's parents
* `george.add_grandparents(paul,nil,nick,mary)` you can skip unknown relatives using nil

* `julian.add_siblings(gina,rita)` will turn gina and rita's parents into the julian's ones

Multiple mating are supported so half parent relationships are admitted and can build separately:

* `luke.add_offspring(julian)` will set only one of julian's parent depending on luke's gender. By the way, given luke is a male, this is of coure equivalent to `julian.add_father(luke)`

* `luke.add_offspring(julian, :mother => gina)` will also change julian's mother. Passing :father option will raise an error if luke is a male

* `walter.add_siblings(luke,paul, :father => jerry)` will turn luke and paul's mother to walter's one and their father to jerry

Methods that involves updates of two or more instances use transactions to ensure the good outcome of the whole operation:

* `george.add_grandparents(paul,gina,nick,mary)` when george's mother is invalid will raise an exception and no one of george's parents get updated.

Removing methods don't take any arguments:

* `george.remove_father` will set to nil george's father_id 
* `george.remove_parents` will set both parents to nil
* `george.remove_paternal_grandfather` will set father george's father to nil
* `george.remove_paternal_grandparents` will set both george's parent to nil
* `george.remove_grandparents` will set all parents' parents to nil
