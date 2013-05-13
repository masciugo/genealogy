require 'spec_helper'
  
module Genealogy
  describe "model and table settings" do

    describe TestModelWithoutSpouse do

      let!(:model){Genealogy.set_model_table(TestModelWithoutSpouse)}
      
      [:father, :mother].each do |parent|
        it "should have #{parent}_id as #{parent} column" do
          model.send("#{parent}_column").should == "#{parent}_id"
        end

        it "should have db column #{parent}_id" do
          model.column_names.should include("#{parent}_id")
        end
      end

      it "should not have db column named spouse_id" do
        model.column_names.should_not include("spouse_id")
      end
      
      it "should not have a spouse_column class attribute" do
        expect { model.spouse_column }.to raise_error(NoMethodError)
      end

    end

    describe TestModelWithSpouse do

      let!(:model){Genealogy.set_model_table(TestModelWithSpouse)}
      
      it "should have spouse_column class attribute" do
        model.spouse_column.should == 'spouse_id'
      end

      it "should have db column named spouse_id" do
        model.column_names.should include("spouse_id")
      end

    end

    describe TestModelWithCustomColumns do

      subject {Genealogy.set_model_table(TestModelWithCustomColumns)}

      {:father_column => "padre", :mother_column => "madre", :spouse_column => "partner", :sex_column => "gender"}.each do |attr,col_name|
        it "should have #{col_name} as #{attr} attribute" do
          subject.send(attr).should == col_name
        end

        it "should have db column named #{col_name}" do
          subject.column_names.should include(col_name)
        end

      end

      it "should have 'M' as sex_male_value" do
        subject.sex_male_value.should == 'M'
      end

      it "should have 'F' as sex_female_value" do
        subject.sex_female_value.should == 'F'
      end

    end

    describe TestModelWithCustomSexValues do
      subject {Genealogy.set_model_table(TestModelWithCustomSexValues)}
      specify { subject.sex_column.should == 'gender' }
      specify { subject.sex_values.should be_a_kind_of(Array) }
      specify { subject.sex_values.should include '1' }
      specify { subject.sex_values.should include '2' }
    end

  end
end
