require File.join(File.expand_path(File.dirname(__FILE__)), 'genealogy/constants')
require File.join(File.expand_path(File.dirname(__FILE__)), 'genealogy/exceptions')
require File.join(File.expand_path(File.dirname(__FILE__)), 'genealogy/util_methods')
require File.join(File.expand_path(File.dirname(__FILE__)), 'genealogy/ineligible_methods')
require File.join(File.expand_path(File.dirname(__FILE__)), 'genealogy/query_methods')
require File.join(File.expand_path(File.dirname(__FILE__)), 'genealogy/complex_query_methods')
require File.join(File.expand_path(File.dirname(__FILE__)), 'genealogy/alter_methods')
require File.join(File.expand_path(File.dirname(__FILE__)), 'genealogy/current_spouse_methods')
require File.join(File.expand_path(File.dirname(__FILE__)), 'genealogy/genealogy')

ActiveRecord::Base.send :include, Genealogy

