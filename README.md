# Genealogy

[![Build Status](https://travis-ci.org/masciugo/genealogy.svg?branch=v1.4.0)](https://travis-ci.org/masciugo/genealogy)

## Description

Genealogy is a ruby gem library which extends ActiveRecord::Base class with familiar relationships capabilities in order to build and query genealogies. If AR records need to be linked and act as they were individuals of a big family, just add two columns for the two parents to its underlying database table (e.g.: *father_id* and *mother_id*) and make your model to call *:has_parents*. This macro will provide your model with the two fundamental self-join associations, *father* and *mother*, which all genealogy functionalities depend on. Let me refer to this model as *genealogized* model.

Genealogy takes inspiration from the simple [linkage file format](http://www.helsinki.fi/~tsjuntun/autogscan/pedigreefile.html) which represents genealogies in terms of set of trios: *individual_id*, *father_id*, *mother_id*. Basically, the only **primitive** familiar relationships are associations father and mother, all the others relationships, like grandparents, siblings or children, are **derived**. This means that all methods in charge of alter the genealogy (adding/removing relatives) will end up to use the fundamental method `add/remove_parent` applied to the right records.

## Installation

To apply Genealogy in its simplest form to any ActiveRecord model, follow these simple steps:

1. Install
    1. Add to Gemfile: gem ‘genealogy’ or, if you want to be on the edge, gem 'genealogy', git: "https://github.com/masciugo/genealogy.git"
    2. Install required gems: bundle install

2. Add required to your table
    1. Create migration: `rails g migration add_parents_to_<table> father_id:integer mother_id:integer [current_spouse_id:integer]`. Read [here](https://github.com/masciugo/genealogy#-current_spouse-) for current spouse column explanation.  A **sex column is also required**, add it if not exists. If necessary, all [column names can be customized](https://github.com/masciugo/genealogy#-column_names-)
    2. Add indexes, separately and in combination, to parents columns
    3. Migrate your database: `rake db:migrate`

3. Add `has_parents` to your model (put after the enum for sex attribute values if present)

## Usage
Genealogized models acquire different kinds of methods: mainly *query methods* and *alter methods*, secondary *ineligible methods*, *scope methods* and *utility methods*

### Query methods
These self explanatory methods simply parse the tree through parents' associations to answer queries. 

Some of them return an AR object, like `father` and `paternal_grandfather`, or nil if is missing. Some other return multiple records. In particular some of them, like `parents` and `grandparents`, return a sorted and fixed lenght *Array* that may include nils, while other like `children` or `siblings` return *ActiveRecord::Relation*. This let you combine the result with other scopes, e.g., `children.males` to retrieve all male children.

Some query methods can take options like `siblings(half: :mother)` which returns maternal half-siblings array (same mother) or `paul.children(spouse: :titty)`which returns all individuals that have paul as father and titty as mother.

### Alter methods
They change the genealogy updating parent external keys of one ore more individuals'. The individuals that are actually modified may differ from the receiver: `peter.add_father(paul)` alters receiver's father attribute while `paul.add_children(julian,mark)` alters arguments' father attribute. 

These methods call internally *save!* so all validations and callbacks are regularly run before completing the operation. Methods that involves updates of two or more instances use transactions to ensure the good outcome of the whole operation. For example if one of peter's parents is invalid for any reason `peter.remove_grandparents` raises an exception and no one of peter's parents get updated.

Like query methods, some of these ones can take options: `paul.add_children(julian, spouse: michelle)` will also change julian's mother to michelle and `julian.add_siblings(peter, half: :father)` will add peter as a paternal half-sibling, that is only peter's father will be updated not mother. 


#### Ineligibility and ineligible methods
Genealogy makes use of *ineligibility* to filter out role-incompatible (technically speaking) individuals in order to prevent altering pedigrees with inconsistent relationships like loops (e.g. peter son of paul and paul son of peter). There are three levels of ineligibility:

* `:off` to disable ineligibility checks. This can be very risky..
* `:pedigree` (default) to run checks based on the pedigree (e.g., an individual cannot have ancestors as children)
* `:pedigree_and_dates` to run checks on pedigree and on individual dates, birth and death, in combination with life expectancy ages and procreation ages (which can be customized by the option `:limit_ages`)

When ineligibility is enabled, before altering the pedigree, internally ineligible methods will be run to get the list of ineligibles individuals. For example during `peter.add_father(paul)` genealogy checks that paul is not among the list returned by `peter.eligible_fathers`.

### Scope methods
Scope methods are class methods of your genealogized model and return list of individuals. `YourModel.males`, for example, returns all males individuals and `YourModel.all_with(:father)` returns all individuals that have a known father.

### Util methods
Util methods are mainly used internally but many of them are public.

## Customization through *has_parents* options
##### `:column_names`
This option takes an hash which by deafult is:

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
This option takes a 2-elements array which by deafult is:

    sex_values: ['M','F']
They represents the value used in the db for gender.

##### `:ineligibility`
This option takes one of symbols `:off`, `:pedigree` and `pedigree_and_dates`. See [here](https://github.com/masciugo/genealogy#ineligibility-and-ineligible-methods) for ineligibility description. Default is `:pedigree`.

##### `:limit_ages`
This option will be taken in consideration only if ineligibility is set on `:pedigree_and_dates` level. It takes an hash which by deafult is:

    limit_ages: {
        min_male_procreation_age: 12,
        max_male_procreation_age: 75,
        min_female_procreation_age: 9,
        max_female_procreation_age: 50,
        max_male_life_expectancy: 110,
        max_female_life_expectancy: 110
    }
Use different values if necessary

##### `:current_spouse`
Other than father and mother also individuals' current spouse can be tracked. To do that just provide option `current_spouse: true` to *has_parents* and make sure that the corresponding foreign key column is present. Do not confuse *current_spouse* with *spouse*, which is intended to refer the individual with whom someone have a child. An individual can have many spouses but only a current spouse.

##### `:perform_validation`
This option let you specify if perform validation or not during *alter methods*. Default is `true`.

## Test as documentation
A rich amount of test examples were written using the RSpec suite. Beyond the canonical testing purpose, I tried to make the test output as human readable as possible in order to serve as auxiliary documentation. Just type *rake* to run all tests on query and alter methods and get the output in a pleasant format.
To best understand genealogy features, I recommend to read first the query methods test outcome (`rake specfile[spec/genealogy/query_methods_spec.rb]`) which was build on [this pedigree](https://github.com/masciugo/genealogy/blob/master/spec/sample_pedigree.pdf)

## Contributing

### Guidelines

#### TODO's

#### Highly desirable features
* Optional usage of current spouse (if defined) for more concise alter methods. For example adding a children to an individual will automatically add it to the current spouse of that individual
* Other more complex query methods like minimal ancestors

### Steps

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Acknowledgement

I'd like to thank all people from Dr. Toniolo's laboratory at San Raffaele Hospital in Milan, especially Dr. Cinzia Sala for her direct help.
