require 'spec_helper'

module ModelSettingsSpec
  extend GenealogyTestModel

  describe 'TestModel' do

    before(:each) { ModelSettingsSpec.define_test_model_class(has_parents_opts) }

    subject { TestModel }

    context 'initialized with options :father_column => "padre", :mother_column => "madre", :current_spouse => true, :current_spouse_column => "partner", :sex_column => "gender"' do
      let(:has_parents_opts) { {:father_column => "padre", :mother_column => "madre", :current_spouse => true, :current_spouse_column => "partner", :sex_column => "gender"} }

      {:father_column => "padre", :mother_column => "madre", :current_spouse_column => "partner", :sex_column => "gender"} .each do |attr,col_name|

        it "should have #{col_name} as #{attr} attribute" do
          TestModel.send(attr).should == col_name
        end

        it "should have db column named #{col_name}" do
          TestModel.column_names.should include(col_name)
        end

      end

      its(:sex_male_value) { should == 'M' }
      its(:sex_female_value) { should == 'F' }

    end

    context 'initialized with options: :sex_column => "gender", :sex_values => [1,2]'  do

      let(:has_parents_opts) { {:sex_column => "gender", :sex_values => [1,2]} }

      its(:sex_column) { should == 'gender'}
      its(:sex_values) { should be_a_kind_of(Array)}
      its(:sex_male_value) { should == 1}
      its(:sex_female_value) { should == 2}

    end

    context 'initialized with options: :sex_values => [:male,:female]'  do

      let(:has_parents_opts) { {:sex_values => [:male,:female]} }

      its(:sex_column) { should == 'sex'}
      its(:sex_values) { should be_a_kind_of(Array)}
      its(:sex_male_value) { should == :male}
      its(:sex_female_value) { should == :female}

    end

    context "initialized with options: :sex_values => ['male','female']"  do

      let(:has_parents_opts) { {:sex_values => ['male','female']} }

      its(:sex_column) { should == 'sex'}
      its(:sex_values) { should be_a_kind_of(Array)}
      its(:sex_male_value) { should == 'male'}
      its(:sex_female_value) { should == 'female'}

    end

    context 'initialized with options: :current_spouse => true' do

      let(:has_parents_opts) { {:current_spouse => true} }

      its(:current_spouse_column) { should == 'current_spouse_id' }
      its(:column_names) { should include("current_spouse_id") }
      its(:current_spouse_enabled) { should be true }

    end

    context "initialized with options: :perform_validation => false" do

      let(:has_parents_opts) { {:perform_validation => false} }

      its(:perform_validation) { should be false }
    end

    context "initialized with default options" do
      let(:has_parents_opts) { {} }

      [:father, :mother].each do |parent|
        it "should have #{parent}_id as #{parent} column" do
          TestModel.send("#{parent}_column").should == "#{parent}_id"
        end

        it "should have db column #{parent}_id" do
          TestModel.column_names.should include("#{parent}_id")
        end
      end

      its(:perform_validation) { should be true }
      its(:column_names) { should_not include("current_spouse_id") }
      its(:current_spouse_enabled) { should be false }

      it "should not have a current_spouse_column class attribute" do
        expect { TestModel.current_spouse_column }.to raise_error(NoMethodError)
      end

    end
  end

  describe "TestModel initialized with wrong options" do

    context "has_parents_opts: {:foo => 'bar' }" do

      let(:has_parents_opts) { {:foo => "bar" } }
      specify { expect { ModelSettingsSpec.define_test_model_class(has_parents_opts) }.to raise_error Genealogy::WrongOptionException }

    end

    context "has_parents_opts: {:foo => 'bar' }" do

      let(:has_parents_opts) { {:sex_column => "gender", :sex_values => [1,2,3]} }
      specify { expect { ModelSettingsSpec.define_test_model_class(has_parents_opts) }.to raise_error Genealogy::WrongOptionException }

    end

  end

end
