require File.join(File.expand_path(File.dirname(__FILE__)), 'genealogy/methods')
# require File.join(File.expand_path(File.dirname(__FILE__)), 'genealogy/exceptions')
require File.join(File.expand_path(File.dirname(__FILE__)), 'genealogy/genealogy')

ActiveRecord::Base.send :extend, Genealogy


