class TestModel < ActiveRecord::Base
  self.table_name = 'test_records'

  attr_accessible :name, :sex

  attr_accessor :always_fail_validation
  validate :check_always_fail_validation

  private

  def check_always_fail_validation
    errors.add(:base, "This object was flagged to always fail") if @always_fail_validation == true
  end

end

class TestModelWithoutSpouse < TestModel
  has_parents
end

class TestModelWithSpouse < TestModel
  has_parents :spouse => true
end

class TestModelWithCustomColumns < TestModel
  has_parents :spouse => true, :father_column => "padre", :mother_column => "madre", :spouse_column => "partner", :sex_column => "gender"
end

class TestModelWithCustomSexValues < TestModel
  has_parents :sex_column => "gender", :sex_values => [1,2]
end

