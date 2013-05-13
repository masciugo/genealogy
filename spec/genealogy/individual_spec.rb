require 'spec_helper'
  
module Genealogy
  describe TestModelWithoutSpouse, "with corrado as subject" do

    let(:model){Genealogy.set_model_table(TestModelWithoutSpouse)}
    
    describe ".new" do 

      subject {model.new(:name => "Corrado")}

      specify { expect { subject.save! }.to raise_error ActiveRecord::RecordInvalid}

      it "has blank parents" do
        subject.sex = 'M'
        subject.save!
        subject.father.should be(nil)
        subject.mother.should be(nil)
      end

    end
    
    subject {model.create!(:name => "Corrado", :sex => "M")}
    let(:uccio) {model.create!(:name => "Uccio")}

    describe "#add_father! (bang method)" do

      it "has uccio as father" do
        subject.add_father!(uccio)
        subject.reload.father.should == uccio
      end

      it "raises an IncompatibleObjectException when adding other class objects" do
        expect { subject.add_father!(Object.new) }.to raise_error(IncompatibleObjectException)
      end

    end


    describe '#add_father (no bang method)' do

      context "without saving" do
        it "has no father" do
          subject.add_father(uccio)
          subject.reload.father.should be(nil)
        end
      end

      context "with saving" do
        it "has uccio as father" do
          subject.add_father(uccio)
          subject.save!
          subject.reload.father.should == uccio
        end
      end

    end

    describe "remove methods" do
      
      before(:each) do
        subject.add_father!(uccio)
      end

      describe "#remove_father! (bang method)" do

        it "has no father" do
          subject.remove_father!
          subject.reload.father.should be_nil
        end

      end


      describe '#remove_father (no bang method)' do

        context "without saving" do
          it "has uccio as father" do
            subject.remove_father
            subject.reload.father.should == uccio
          end
        end

        context "with saving" do
          it "has no father" do
            subject.remove_father
            subject.save!
            subject.reload.father.should be_nil
          end
        end

      end

    end

    describe "add grandparents methods" do
      
      let(:uccio) {model.create!(:name => "Uccio")}
      let(:narduccio) {model.create!(:name => "Narduccio")}
      let(:maria) {model.create!(:name => "Maria")}
      let(:tetta) {model.create!(:name => "Tetta")}
      let(:antonio) {model.create!(:name => "Antonio")}
      let(:assunta) {model.create!(:name => "Assunta")}

      describe "paternal lineage" do
        
        before(:each) do
          subject.add_father!(uccio)
        end

        describe '#add_paternal_grandfather!' do
          it "has narduccio as paternal grandfather" do
            subject.add_paternal_grandfather!(narduccio)
            subject.reload.paternal_grandfather.should == narduccio
          end

          context "when it has no father" do
            it "raises a LineageGapException" do
              subject.remove_father!
              expect { subject.add_paternal_grandfather!(narduccio) }.to raise_error(LineageGapException)
            end
          end
        end

        describe '#add_paternal_grandmother!' do
          it "has maria as paternal grandmother" do
            subject.add_paternal_grandmother!(maria)
            subject.reload.paternal_grandmother.should == maria
          end
        end

      end

      describe "maternal lineage" do
        
        before(:each) do
          subject.add_mother!(tetta)
        end

        describe '#add_maternal_grandfather!' do
          it "has antonio as maternal grandfather" do
            subject.add_maternal_grandfather!(antonio)
            subject.reload.maternal_grandfather.should == antonio
          end
        end

        describe '#add_maternal_grandmother!' do
          it "has assunta as maternal grandmother" do
            subject.add_maternal_grandmother!(assunta)
            subject.reload.maternal_grandmother.should == assunta
          end
        end

      end

    end

    describe "offspring query methods" do

      let!(:uccio) {model.create!(:name => "Uccio", :sex => "M")}
      let!(:tetta) {model.create!(:name => "Tetta", :sex => "F")}
      let!(:gina) {model.create!(:name => "Gina", :sex => "F")}
      let!(:stefano) {model.create!(:name => "Stefano", :sex => "M")}
      let!(:corrado) {model.create!(:name => "Corrado", :sex => "M")}
      let!(:walter) {model.create!(:name => "Walter", :sex => "M")}

      before(:each) do
        corrado.add_father!(uccio)
        corrado.add_mother!(tetta)
        stefano.add_father!(uccio)
        stefano.add_mother!(tetta)
        walter.add_father!(uccio)
        walter.add_mother!(gina)
      end

      describe "tetta offspring" do
        subject {tetta.offspring}
        specify { should include corrado,stefano }
        specify { should_not include walter }
      end

      describe "uccio offspring" do
        subject {uccio.offspring}
        specify { should include corrado,stefano,walter }
      end

      describe "gina offspring" do
        subject {gina.offspring}
        specify { should include walter }
        specify { should_not include corrado,stefano }
      end

    end

    describe "siblings", :wip => true do

      let!(:uccio) {model.create!(:name => "Uccio", :sex => "M")}
      let!(:tetta) {model.create!(:name => "Tetta", :sex => "F")}
      let!(:gina) {model.create!(:name => "Gina", :sex => "F")}
      let!(:stefano) {model.create!(:name => "Stefano", :sex => "M")}
      let!(:corrado) {model.create!(:name => "Corrado", :sex => "M")}
      let!(:walter) {model.create!(:name => "Walter", :sex => "M")}
      let!(:dylan) {model.create!(:name => "Dylan", :sex => "M")}

      describe "query methods: #siblings and #half_siblings" do
        
        before(:each) do
          corrado.add_father!(uccio)
          corrado.add_mother!(tetta)
          stefano.add_father!(uccio)
          stefano.add_mother!(tetta)
          walter.add_father!(uccio)
          walter.add_mother!(gina)
        end

        describe "corrado siblings" do
          subject { corrado.siblings }
          specify { should include stefano }
          specify { should_not include walter,corrado }
        end

        describe "walter siblings" do
          subject { walter.siblings }
          specify { should be_empty }
        end

        describe "corrado half siblings" do
          subject {corrado.half_siblings}
          specify { should include walter }
          specify { should_not include stefano }
        end

        describe "dylan (whose both parents are nil) siblings" do
          subject { dylan.siblings }
          specify { should be_nil }
        end
      end

      describe "adding methods" do

        before(:each) do
          corrado.add_father!(uccio)
          corrado.add_mother!(tetta)
        end

        describe "#add_siblings!" do

          context "when add_sibling! stefano to corrado" do
            before(:each) do
              corrado.add_siblings!(stefano)
            end

            describe "corrado siblings" do
              subject { corrado.siblings }
              specify {should include stefano}
            end

            describe "stefano siblings" do
              subject { stefano.siblings }
              specify {should include corrado}
            end

          end

          context "when add_sibling! stefano to corrado but something goes wrong while saving stefano" do

            before(:each) do
              stefano.always_fail_validation = true
            end

            specify { expect { corrado.add_siblings!(stefano) }.to raise_error ActiveRecord::RecordInvalid }

            describe "corrado siblings" do
              subject { corrado.siblings }
              specify { expect { corrado.add_siblings!(stefano) }.to raise_error ActiveRecord::RecordInvalid and corrado.reload.siblings.should_not include stefano }
            end

            describe "stefano siblings" do
              subject { stefano.siblings }
              specify { expect { corrado.add_siblings!(stefano) }.to raise_error ActiveRecord::RecordInvalid and stefano.reload.siblings.should be_nil}
            end

          end


        end

        describe "#add_siblings" do
          
          context "when add_sibling stefano to corrado" do

            before(:each) do
              corrado.add_siblings(stefano)
            end

            context "and stefano is saved" do

              before(:each) do
                stefano.save!
              end

              describe "corrado siblings" do
                subject { corrado.reload.siblings }
                specify {should include stefano}
              end

              describe "stefano siblings" do
                subject { stefano.reload.siblings }
                specify {should include corrado}
              end

            end

            context "and stefano is not saved" do

              describe "corrado siblings" do
                subject { corrado.reload.siblings }
                specify {should_not include stefano}
              end

              describe "stefano siblings" do
                subject { stefano.reload.siblings }
                specify {should be_nil}
              end

            end

          end

          context "when add_sibling to (whose both parents are nil)" do

            specify { expect { dylan.add_siblings(stefano) }.to raise_error LineageGapException }

          end

        end

      end

    end

  end
end
