# Genealogy

Genealogy is a ruby gem library which enhance ActiveRecord models with familiar relationships capabilities in order to build or query genealogies. If records of your model need to be connected and act as they were a family just add two parents column to its table (ie.: *father_id* and *mother_id*) and make your model to *:has_parents*. This macro will provide the two fundamental self-join associations, *father* and *mother*, whose everything depend on.  
Genealogy takes inspiration from the simple [linkage file format](http://www.helsinki.fi/~tsjuntun/autogscan/pedigreefile.html) which represent genealogies in terms of set of trios: *individual_id*, *father_id*, *mother_id*. Basically the only primitive familiar relationships are associations father and mother, all others like grandparents, siblings or offspring are derived. This means that all methods in charge of update the genealogy (adding/removing relatives) will end up to use the fundamental method add/remove_parent to the right records

## Installation

To apply Ancestry to any ActiveRecord model, follow these simple steps:  
1.  Install   
    1.  Add to Gemfile: gem ‘genealogy’   
    2.  Install required gems: bundle install    
2. Add ancestry column to your table     