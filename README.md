# Genealogy

[![Build Status](https://travis-ci.org/masciugo/genealogy.svg?branch=v1.4.0)](https://travis-ci.org/masciugo/genealogy)

## Description

Genealogy is a ruby gem library which extends ActiveRecord models in order to make its instances act as relatives so that you can build and query genealogies. To do that every instance need to keep track of its mother and father, so just add the two external key columns to the underlying database table (e.g.: *father_id* and *mother_id*) and make the model call *:has_parents*. This macro will provide it with the two fundamental self-join associations, *father* and *mother*, which all genealogy functionalities depend on. 

Genealogy takes inspiration from the simple [linkage file format](http://www.helsinki.fi/~tsjuntun/autogscan/pedigreefile.html) which represents genealogies in terms of set of trios: *individual_id*, *father_id*, *mother_id*. Basically, the only **primitive** familiar relationships are associations father and mother, all the others relationships, like grandparents, siblings or children, are **derived**. This means that all methods in charge of alter the genealogy (adding/removing relatives) will end up to execute one or more `add_parent` or `remove_parent` on the right objects.

## Installation

1. Install
    1. Add to Gemfile: gem ‘genealogy’ or, if you want to be on the edge, gem 'genealogy', git: "https://github.com/masciugo/genealogy.git"
    2. Install required gems: bundle install

2. Alter model table
    
    * Add required columns to your table if they not exists: For example:
    
    `rails g migration add_parents_to_<table> sex:string father_id:integer mother_id:integer [current_spouse_id:integer]`. 

    Read [here](#current_spouse) for optional current spouse column explanation. If necessary, all [column names can be customized](#column_names)
    
    * Add indexes, separately and in combination, to parents columns

3. Add `has_parents` to your model (put after the enum for sex attribute values if present)

## Usage
*Genealogized* models acquire different kinds of methods: from the user point of view the most important are *query methods* and *alter methods*, secondary *ineligible methods*, *scope methods* and *utility methods*. The following is a simple overview, please go [here](#test-and-documentation-together) for a better understanding of the library.

### Query methods
These self explanatory methods simply parse the tree (through parents' associations) in order to respond to relatives queries. 

Some of them return a single AR object, like `father` and `paternal_grandfather`, or nil if is missing. Some other return multiple records. In particular some of them, like `parents` and `grandparents`, return a sorted and fixed lenght *Array* that may include nils, while other like `children` or `siblings` return *ActiveRecord::Relation* as they can be of any length. This let you combine their outcome with other scopes:  `children.males` returns all male children.

Some query methods can take options: `siblings(half: :mother)` returns maternal half-siblings (same mother). `paul.children(spouse: :titty)` returns all individuals that have paul as father and titty as mother.

### Alter methods
They change the genealogy updating parent external keys of one ore more individuals. The individuals that are actually modified may differ from the receiver: 
* `peter.add_father(paul)` alters the receiver, peter's *father_id* gets updated
* `paul.add_children(julian,mark)` alters the arguments, julian mark's *father_id* gets updated
* `peter.add_paternal_grandfather(manuel)` alters neither the receiver nor the argument, paul's (peter's father) *father_id* gets updated

These methods call internally *save!* so all validations and callbacks are regularly run before completing the operation. Methods that involves updates of two or more instances use transactions to ensure the good outcome of the whole operation. For example `peter.remove_grandparents` raises an exception and no one of peter's parents get updated if one of peter's parents is invalid for any reason.

Like query methods, they can take options: `paul.add_children(julian, spouse: michelle)` will also update julian's mother to michelle and `julian.add_siblings(peter, half: :father)` will add peter as a paternal half-sibling, that is only peter's father will be updated not mother. 


#### Ineligibility and ineligible methods
*Genealogy* makes use of the concept of *ineligibility*: it blocks role-incompatible individuals in order to prevent meaningless relationships like females as father or loops (e.g. peter son of paul and paul son of peter). To suit the desired compromise between performances and consistency there are three levels of ineligibility:

* `:off` ineligibility checks are disabled. Consistency is up to the user. Mistakes can lead to unpredictable behaviors
* `:pedigree` (default) checks are based on the pedigree (e.g., an individual cannot have ancestors as children)
* `:pedigree_and_dates` checks are based on pedigree and on individual dates, birth and death, in combination with life expectancy ages and procreation ages (see [here](#limit_ages) to change them)

When ineligibility is enabled, before altering the pedigree, ineligible methods will be run to get the list of ineligibles individuals. For example during `peter.add_father(paul)` genealogy checks that paul is not among the list returned by `peter.eligible_fathers`. **Be aware to the fact that ineligibles methods help users to avoid many conceptual errors but not all: besides their output list some other individuals may be ineligibles according to other and more complex lines of reasoning.** 

### Scope methods
Scope methods are class methods of your *genealogized* model and return list of individuals. `YourModel.males`, for example, returns all males individuals and `YourModel.all_with(:father)` returns all individuals that have a known father.

### Utility methods
Utility methods are mainly used internally but many of them are public.

## Customization through *has_parents* options
##### `:column_names`
This option takes an hash which by default is:

    column_names: {
        sex: 'sex',
        father_id: 'father_id',
        mother_id: 'mother_id',
        current_spouse_id: 'current_spouse_id',
        birth_date: 'birth_date',
        death_date: 'death_date'
    }
Pass different values to map legacy db.

##### `:sex_values`
This option takes a 2-elements array which by default is:

    sex_values: ['M','F']
They represents the value used in the db for gender.

##### `:ineligibility`
This option takes one of symbols `:off`, `:pedigree` and `pedigree_and_dates`. See [here](#ineligibility-and-ineligible-methods) for ineligibility description. Default is `:pedigree`.

##### `:limit_ages`
This option will be taken in consideration only if ineligibility is set on `:pedigree_and_dates` level. It takes an hash which by default is:

    limit_ages: {
        min_male_procreation_age: 12,
        max_male_procreation_age: 75,
        min_female_procreation_age: 9,
        max_female_procreation_age: 50,
        max_male_life_expectancy: 110,
        max_female_life_expectancy: 110
    }

##### `:current_spouse`
Other than father and mother also individuals' current spouse can be tracked. To do that just provide option `current_spouse: true` and make sure that the corresponding foreign key column is present. Do not confuse *current_spouse* with *spouse*, which is intended to refer the individual with whom someone have a child. An individual can have many spouses but only a current spouse.

##### `:perform_validation`
This option let you specify whether perform validation or not during *alter methods*. Default is `true`.

## Test and documentation, together
A rich amount of test examples were written using the RSpec 3 suite. Beyond the canonical testing purpose, I tried to make the test outcome as much explanatory as possible so that can be used as an auxiliary documentation, along with the [standard documentation](). Give it a try simply running `rake` and get behavior description of all methods in a pleasant format. In particular query methods spec is based on [this pedigree](https://github.com/masciugo/genealogy/blob/master/spec/sample_pedigree.pdf). Run it separately with `rake specfile[spec/genealogy/query_methods_spec.rb]`

## Contributing

### TODO's

* improve performances
* optional usage of current spouse (if defined) for more concise alter methods. For example adding a children to an individual will also add it to the current spouse of the receiver
* adding more complex query methods like minimal ancestors

### Steps

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Acknowledgement
I'd like to thank all people from Dr. Toniolo's laboratory at San Raffaele Hospital in Milan, Italy, especially Dr. Cinzia Sala for her direct help.
