# Genealogy

## Premise
Genealogy is still under development and need to be improved and extended. The developed features so far were the ones I needed for my personal applications where I had to provide data entry facilities to insert, given an individual, relatives' vital records and keep track of their familiar relationships. However, they are the basic features for a genealogy management system and that's why I decided to extract it in a gem. So please use with care but, above all, use it with critical and constructive sense as I am really interested in improving it.


## Description

Genealogy is a ruby gem library which extends ActiveRecord::Base class with familiar relationships capabilities in order to build and query genealogies. If records of your model need to be linked and act as they were individuals of a big family, just add two columns for the two parents to its table (e.g.: *father_id* and *mother_id*) and make your model to *:has_parents*. This macro will provide your model with the two fundamental self-join associations, *father* and *mother, from which everything depends on.  
Genealogy takes inspiration from the simple [linkage file format](http://www.helsinki.fi/~tsjuntun/autogscan/pedigreefile.html) which represents genealogies in terms of set of trios: *individual_id*, *father_id*, *mother_id*. Basically, the only **primitive** familiar relationships are associations father and mother, all the others relationships, like grandparents, siblings or offspring, are **derived**. This means that all methods in charge of alter the genealogy (adding/removing relatives) will end up to use the fundamental method `add/remove_parent` applied to the right records.

## Installation

To apply Genealogy in its simplest form to any ActiveRecord model, follow these simple steps:  

1. Install   
    1. Add to Gemfile: gem ‘genealogy’ or, if you want to be always on the edge, gem 'genealogy', :git => "https://github.com/masciugo/genealogy.git"
    2. Install required gems: bundle install    

2. Add the foreign key parents columns to your table     
    1. Create migration: `rails g migration add_parents_to_<table> father_id:integer mother_id:integer [current_spouse_id:integer]`. A **sex column is also required**, add it if not exists. Read [here](https://github.com/masciugo/genealogy#current-spouse-option) for spouse column explanation.
    2. Add index separately and in combination to parents columns   
    3. Migrate your database: `rake db:migrate`

3. Add `has_parents` to your model (to put after a possible enum for sex attribute values)

## Usage

As the original aim was to add relatives concerning a specific individual, all relevant methods are instance methods called on that individual. They are of two kinds: *query methods* and *alter methods*

### Query methods

These self explanatory methods simply parse the tree through parents' associations to answer queries. 

* `peter.father` will retrieve peter's father
* `peter.paternal_grandfather` will retrieve parents of peter's father 

Some methods return a sorted array:

* `peter.parents` will retrieve peter's parents as 2 elements sorted array: [father,mother] 
* `peter.paternal_grandparents` will return a 2 elements sorted array: [paternal_grandfather, paternal_granmother]
* `peter.grandparents` will return a 4 elements sorted array: [paternal_grandfather, paternal_granmdother, maternal_grandfather, maternal_grandmother]

Some other return an unsorted array:

* `peter.ancestors` will return an unsorted array
* `peter.descendants` same as above

Genealogy strongly considers multiple mates procreation so siblings and offspring are really featured methods:  

* `peter.siblings` will return full-siblings array (same father and mother)
* `peter.siblings(:half => :mother)` will return maternal half-siblings array (same mother)
* `peter.maternal_half_siblings` just a shortcut
* `peter.siblings(:half => :only)` will return only half-siblings 
* `peter.half_siblings` just a shortcut
* `peter.siblings(:half => :father, :spouse => :titty)` will return paternal half-siblings but the ones he had with titty
* `peter.siblings(:half => :include)` will return all kind of siblings: full and half
* `paul.offspring` will return all individuals that have paul as father (mother can be any)
* `paul.offspring(:spouse => :titty)` will return all individuals that have paul as father and titty as mother
* `paul.offspring(:spouse => nil)` will return all individuals that have paul as father and an unknown mother
* `paul.spouses` will return all individuals that have had children with paul. Result will include nil if paul has had children with unknown spouse

There are also some other miscellaneous query methods like:

* `peter.uncles_and_aunts` will return siblings of parents
* `peter.uncles_and_aunts(:sex => male)` will return only male siblings of parents
* `peter.uncles` shortcut for above
* `peter.uncles_and_aunts(:sex => male, :lineage => :paternal)` will return only male siblings of father
* `peter.paternal_uncles` shortcut for above
* `peter.uncles_and_aunts(:sex => male, :lineage => :maternal)` will return only male siblings of mother
* `peter.maternal_uncles` shortcut for above
* `peter.uncles_and_aunts(:sex => female)` will return only female siblings of parents
* `peter.aunts` shortcut for above
* `peter.uncles_and_aunts(:sex => female, :lineage => :paternal)` will return only female siblings of father
* `peter.paternal_aunts` shortcut for above
* `peter.uncles_and_aunts(:sex => female, :lineage => :maternal)` will return only female siblings of mother
* `peter.maternal_aunts` shortcut for above
* `peter.grandchildren`
* `peter.great_grandchildren` will return offspring of grandchildren
* `peter.great_grandparents` will return parents of grandparents
* `peter.nieces_and_nephews(options={}, sibling_options={})` will consider full-siblings by default, but the second argument hash can modify this if desired
* `peter.nieces_and_nephews(:sex => male)` will return all male offspring of silbings
* `peter.nephews` shortcut for above
* `peter.nieces_and_nephews(:sex => female)` will return all female offspring of silbings
* `peter.nieces` shortcut for above
* `peter.cousins` will return offspring of siblings of parents
* `peter.family` will return peter's folks: offspring, parents and all spouses (that are the union of all children's parents) 
* `peter.family(:half => :include)` will also consider half_siblings 
* `peter.extended_family` will also consider grandparents, grandchildren, uncles, aunts, nieces, nephews

Others methods called *eligible_ methods* can be used to pre-filter role-compatible (technically speaking) genealogy individuals. For example:

* `peter.eligible_fathers` will return all genealogy male individuals excluding peter's descendants. It will return an empty array if peter has already a father.

* `peter.eligible_paternal_grandfathers` will be the same as `peter.father.eligible_fathers`

* `peter.eligible_siblings` will return all genealogy individuals excluding ancestors, all kind of  siblings and himself
* `peter.eligible_offspring` will return all genealogy individuals excluding ancestors, offspring, full siblings and himself
* `peter.eligible_spouses` will return all opposite sex genealogy individuals excluding spouses

### Alter methods

They change the genealogy updating one ore more target individuals (the ones that are actually modified). These methods overwrite old values and call internally *save!* so all validation and callbacks are regularly run. Here are some examples where target individual correspond with method's receiver:

* `peter.add_father(peter)` will change peter's father_id to peter.id
* `peter.add_father(paul)` will overwrite peter's father_id
* `peter.add_mother(titty)` 
* `peter.add_parents(paul,titty)` 

Not always the method's receiver is the instance that get updated (target record):

* `peter.add_paternal_grandmother(terry)` will change mother of peter's father. No changes for paul and titty. It can seem weird but think about it as an intuitive shortcut to quickly build the genealogy as a whole entity.

* `peter.add_paternal_grandparents(manuel, terry)` will change parents of peter's father like the *add_parents* method does.

Some methods can take a list of individuals:

* `peter.add_grandparents(manuel,terry,paso,irene)` will change both paul's parents
* `peter.add_grandparents(manuel,nil,paso,irene)` you can skip unknown relatives using nil

* `julian.add_siblings(beatrix)` will turn beatrix's parents into the julian's ones

Multiple mating are supported so half parent relationships are admitted and can build separately:

* `paul.add_offspring(julian)` will set only one of julian's parent depending on paul's gender. By the way, given paul is a male, this is of course equivalent to `julian.add_father(paul)`
* `paul.add_offspring(julian, :spouse => michelle)` will also change julian's mother

* `julian.add_siblings(peter, :half => :father)` will add peter as a paternal half-sibling, that is only peter's father will be changed to julian's one
* `julian.add_siblings(peter, :half => :father, :spouse => titty)` will also change peter's mother to titty. This let set a different mother for the sibling

Methods that involves updates of two or more instances use transactions to ensure the good outcome of the whole operation:

* `peter.add_grandparents(paul,titty,nick,mary)` when peter's mother is invalid will raise an exception and no one of peter's parents get updated.

Removing methods examples are:

* `peter.remove_father` will set to nil peter's father_id 
* `peter.remove_parents` will set both parents to nil
* `peter.remove_paternal_grandfather` will set father peter's father to nil
* `peter.remove_paternal_grandparents` will set both peter's parent to nil
* `peter.remove_grandparents` will set all parents' parents to nil
*
* `peter.remove_offspring` will nullify the father of all that records that have peter as father
* `peter.remove_offspring(:affect_spouse => true)` will also nullify mother of all that records that have peter as father
* `peter.remove_offspring(:spouse => titty)` will nullify the father of all that records that have peter as father and titty as mother
* `peter.remove_offspring(:spouse => titty, :affect_spouse => true)` will do both last two actions

* `peter.remove_siblings` will nullify both full-siblings parents
* `peter.remove_siblings(:half => :father)` will nullify only father of all records that have same peter's father as father
* `peter.remove_siblings(:half => :father, :affect_spouse => true)` will nullify also mother of all records that have same peter's father as father

### Class methods

* `YourModel.males` will return all males individuals
* `YourModel.females` will return all females individuals


## *has_parents* options

Some options are available to suit your existing table: 

    class Individual<ActiveRecord::Base
      has_parents :father_column => "padre", :mother_column => "madre", :sex_column => "gender", :sex_values => [1,2]
    end

### current spouse option

You can also consider current individual's consort providing the option `:current_spouse => true` which will make genealogy to keep track of the current spouse through the extra current_spouse association. The term 'spouse' here is really different from the spouse mentioned so far, which was intended to refer the individual with whom someone bred someone else. current_spouse association, for the moment, never comes into play while querying or building the genealogy on derived familiar relationships! In the future current_spouse association can be used to add/remove siblings/offspring in a more concise way.

### perform_validation option

perform_validation option let you specify if child record, while altering its parents, has to perform validation or not. Default is true but sometimes the record could be affected by other validation errors not depending on genealogy gem

### defaults

    father_column: 'father_id'   
    mother_column: 'mother_id'   
    current_spouse_column: 'current_spouse_id'   
    sex_column: 'sex'   
    sex_values: ['M','F']   
    perform_validation: true

## Test as documentation

A rich amount of test examples were written using the RSpec suite. Beyond the canonical testing purpose, I tried to make the test output as human readable as possible in order to serve as auxiliary documentation. Just type *rake* to run all tests on query and alter methods and get the output in a pleasant format. 
To best understand genealogy features, I recommend to read first the query methods test outcome (`rake specfile[spec/genealogy/query_methods_spec.rb]`) which was build on [this pedigree](https://github.com/masciugo/genealogy/blob/master/spec/sample_pedigree.pdf) 

## Contributing

### Guidelines

#### TODO's

* documentation
* better description of new query method usage: [paternal|maternal] nieces, nephews, aunts, uncles along with their options

#### Highly desirable features

* Optional usage of current spouse (if defined) for more concise alter methods. For example adding a children to an individual will automatically add it to the current spouse of that individual
* Date of birth introduction along with checks based on it for better eligible methods
* Other more complex query methods like minimal ancestors

### Steps

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Acknowledgement

I'd like to thank all people from Dr. Toniolo's laboratory at San Raffaele Hospital in Milan, especially Dr. Cinzia Sala for her direct help.
