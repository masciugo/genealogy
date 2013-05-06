require 'spec_helper'

load_schema

module Genealogy
  describe "Individual genealogy extension" do

    # reset Individul genealogy extension
    before(:each) do
      reset_individual_class
    end

    context "without options (defaults)" do

      before(:each) do
        Individual.has_parents
      end

      [:father, :mother].each do |parent|
        it "should have #{parent}_id as #{parent} column" do
          Individual.send("#{parent}_column").should == "#{parent}_id"
        end

        it "should have db column #{parent}_id" do
          Individual.column_names.should include("#{parent}_id")
        end
      end

      it "should not have a spouse_column class attribute" do
        expect { Individual.spouse_column }.to raise_error(NoMethodError)
      end

    end

    context "with spouse option" do

      before(:each) do
        Individual.has_parents :spouse => true
        Individual.table_name = "individuals_with_spouse"
      end

      it "should have spouse_column class attribute" do
        Individual.spouse_column.should == 'spouse_id'
      end

      it "should have db column named spouse_id" do
        Individual.column_names.should include("spouse_id")
      end

    end

    context "with custom column names" do

      options = {:father_column => "padre", :mother_column => "madre", :spouse_column => "partner"}

      before(:each) do
        Individual.has_parents options.merge(:spouse => true)
        Individual.table_name = "individuals_with_custom_parent_cols"
      end

      options.each do |attr,col_name|
        it "should have #{col_name} as #{attr} attribute" do
          Individual.send(attr).should == col_name
        end

        it "should have db column named #{col_name}" do
          Individual.column_names.should include(col_name)
        end

      end

    end

  end
end
