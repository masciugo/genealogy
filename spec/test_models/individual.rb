class TestModel < ActiveRecord::Base
  self.table_name = 'test_records'

  attr_accessible :name

end

class TestModel1 < TestModel

end

class TestModel2 < TestModel
  
end

class TestModel3 < TestModel
  
end
