require 'spec_helper'

module QueryMethodsSpec
  extend GenealogyTestModel
  
  describe "*** Query methods ***"  do

    before(:all) do
      QueryMethodsSpec.define_test_model_class({:spouse => true })
    end

    let!(:paul) {TestModel.create!(:name => "paul", :sex => "M", :father_id => manuel.id, :mother_id => terry.id)}
    let!(:titty) {TestModel.create!(:name => "titty", :sex => "F", :father_id => paso.id, :mother_id => irene.id)}
    let!(:peter) {TestModel.create!(:name => "peter", :sex => "M", :father_id => paul.id, :mother_id => titty.id)}
    let!(:mary) {TestModel.create!(:name => "mary", :sex => "F", :father_id => paul.id, :mother_id => barbara.id)}
    let!(:barbara) {TestModel.create!(:name => "barbara", :sex => "F", :father_id => john.id, :mother_id => maggie.id)}
    let!(:paso) {TestModel.create!(:name => "paso", :sex => "M")}
    let!(:irene) {TestModel.create!(:name => "irene", :sex => "F", :father_id => tommy.id, :mother_id => emily.id)}
    let!(:manuel) {TestModel.create!(:name => "manuel", :sex => "M")}
    let!(:terry) {TestModel.create!(:name => "terry", :sex => "F", :father_id => marcel.id)}
    let!(:john) {TestModel.create!(:name => "john", :sex => "M", :father_id => jack.id, :mother_id => alison.id)}
    let!(:jack) {TestModel.create!(:name => "jack", :sex => "M", :father_id => bob.id, :mother_id => louise.id)}
    let!(:bob) {TestModel.create!(:name => "bob", :sex => "M")}
    let!(:debby) {TestModel.create!(:name => "debby", :sex => "F", :father_id => bob.id, :mother_id => louise.id)}
    let!(:alison) {TestModel.create!(:name => "alison", :sex => "F")}
    let!(:maggie) {TestModel.create!(:name => "maggie", :sex => "F")}
    let!(:emily) {TestModel.create!(:name => "emily", :sex => "F", :father_id => luis.id, :mother_id => rosa.id)}
    let!(:tommy) {TestModel.create!(:name => "tommy", :sex => "M", :father_id => larry.id, :mother_id => louise.id)}
    let!(:luis) {TestModel.create!(:name => "luis", :sex => "M")}
    let!(:rosa) {TestModel.create!(:name => "rosa", :sex => "F")}
    let!(:larry) {TestModel.create!(:name => "larry", :sex => "M")}
    let!(:louise) {TestModel.create!(:name => "louise", :sex => "F")}
    let!(:ned) {TestModel.create!(:name => "ned", :sex => "M")}
    let!(:steve) {TestModel.create!(:name => "steve", :sex => "M", :father_id => paul.id, :mother_id => titty.id)}
    let!(:naomi) {TestModel.create!(:name => "naomi", :sex => "F")}
    let!(:michelle) {TestModel.create!(:name => "michelle", :sex => "F", :father_id => ned.id, :mother_id => naomi.id)}
    let!(:marcel) {TestModel.create!(:name => "marcel", :sex => "M")}
    let!(:beatrix) {TestModel.create!(:name => "beatrix", :sex => "F", :father_id => paul.id, :mother_id => michelle.id)}
    let!(:julian) {TestModel.create!(:name => "julian", :sex => "M", :father_id => paul.id, :mother_id => michelle.id)}

    describe "peter" do
      subject {peter}
      its(:parents) {should =~ [paul,titty]}
      its(:paternal_grandfather) {should == manuel}
      its(:paternal_grandmother) {should == terry}
      its(:maternal_grandfather) {should == paso}
      its(:maternal_grandmother) {should == irene}
      its(:grandparents) {should =~ [manuel,terry,paso,irene]}
      its(:siblings) {should =~ [steve]}
      its(:paternal_grandparents) {should =~ [manuel,terry]}
      its(:maternal_grandparents) {should =~ [paso,irene]}
      its(:half_siblings) {should =~ [mary,julian,beatrix]}
      its(:ancestors) {should =~ [paul,titty,manuel,terry,paso,irene,tommy,emily,larry,louise,luis,rosa,marcel]}
    end

    describe "mary" do
      subject {mary}
      its(:parents) {should =~ [paul,barbara]}
      its(:paternal_grandfather) {should == manuel}
      its(:paternal_grandmother) {should == terry}
      its(:maternal_grandfather) {should == john}
      its(:maternal_grandmother) {should == maggie}
      its(:paternal_grandparents) {should =~ [manuel,terry]}
      its(:maternal_grandparents) {should =~ [john,maggie]}
      its(:grandparents) {should =~ [manuel,terry,john,maggie]}
      its(:half_siblings) { should =~ [peter,julian,beatrix,steve] }
      its(:descendants) {should be_empty}
      its(:siblings) { should_not include peter }
      its(:ancestors) {should =~ [paul,barbara,manuel,terry,john,maggie,marcel,jack,alison,bob,louise]}
    end

    describe "beatrix" do
      subject {beatrix}
      its(:parents) {should =~ [paul,michelle]}
      its(:siblings) {should =~ [julian]}
      its(:half_siblings) {should =~ [peter,steve,mary]}
      its(:paternal_half_siblings) {should =~ [peter,steve,mary]}
      describe "all half_siblings and siblings: #siblings(:half => :include)" do
        specify {beatrix.siblings(:half => :include).should =~ [peter,steve,mary,julian]}
      end  
      describe "half_siblings with titty: #siblings(:half => father, :spouse => titty)" do
        specify {beatrix.siblings(:half => :father, :spouse => titty).should =~ [peter,steve]}
      end
      describe "half_siblings with mary: #siblings(:half => father, :spouse => barbara)" do
        specify {beatrix.siblings(:half => :father, :spouse => barbara).should =~ [mary]}
      end  
    end

    describe "paul" do
      subject {paul}
      its(:parents) {should =~ [manuel,terry]}
      its(:offspring) {should =~ [peter,mary,julian,beatrix,steve]}
      describe "#offspring(:spouse => barbara)" do
        specify { paul.offspring(:spouse => barbara).should =~ [mary] }
      end
      describe "#offspring(:spouse => michelle)" do
        specify { paul.offspring(:spouse => michelle).should =~ [julian,beatrix] }
      end
      its(:descendants) {should =~ [peter,mary,julian,beatrix,steve]}
      its(:ancestors) {should =~ [manuel,terry,marcel]}
      its(:maternal_grandmother) {should be_nil}
      its(:maternal_grandparents) {should =~ [marcel,nil]}
      its(:grandparents) {should =~ [nil,nil,marcel,nil]}
    end

    describe "terry" do
      subject {terry}
      its(:father) {should == marcel}
      its(:mother) {should be_nil}
      its(:parents) {should =~ [marcel,nil]}
      its(:ancestors) {should =~ [marcel]}
    end

    describe "barbara" do
      subject {barbara}
      its(:offspring) {should =~ [mary]}
      describe "offspring with manuel" do
        specify { barbara.offspring(:spouse => manuel).should be_empty }
      end
      its(:descendants) {should =~ [mary]}
      its(:grandparents) {should =~ [jack,alison,nil,nil]}
    end
    
    describe "paso" do
      subject {paso}
      its(:offspring) {should =~ [titty]}
      its(:descendants) {should =~ [titty,peter,steve]}
    end

    describe "louise" do
      subject {louise}
      its(:offspring) {should =~ [tommy,jack,debby]}
      its(:descendants) {should =~ [tommy, irene, titty, peter, jack, john, barbara, mary, debby, steve]}
      its(:ancestors) {should be_empty}
      its(:father){should be_nil}
      its(:parents){should be_empty}
    end

  end

end