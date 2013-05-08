require 'spec_helper'
  
module Genealogy
  describe "model genealogy settings" do

    context "without options (defaults)" do

      let!(:model){Genealogy.set_test_model(TestModel1)}
      
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

    context "with spouse option" do

      let!(:model){Genealogy.set_test_model(TestModel1, :spouse => true)}
      
      it "should have spouse_column class attribute" do
        model.spouse_column.should == 'spouse_id'
      end

      it "should have db column named spouse_id" do
        model.column_names.should include("spouse_id")
      end

    end

    context "with custom column names" do

      let!(:model){Genealogy.set_test_model(TestModel1, {:father_column => "padre", :mother_column => "madre", :spouse_column => "partner"}.merge(:spouse => true))}

      {:father_column => "padre", :mother_column => "madre", :spouse_column => "partner"}.each do |attr,col_name|
        it "should have #{col_name} as #{attr} attribute" do
          model.send(attr).should == col_name
        end

        it "should have db column named #{col_name}" do
          model.column_names.should include(col_name)
        end

      end

    end

  end
end
