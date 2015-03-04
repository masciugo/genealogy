# require 'spec_helper'

# describe "*** Alter children methods ***", :done, :alter_c  do

#   context "when taking account validation (default options for has_parents)" do
#     before { @model = get_test_model({}) }
  
#     include_context 'unreleted people exist'

#     describe "paul.add_children(peter)" do
#       subject { paul.add_children(peter) }
#       it { is_expected.to be true }
#       it { is_expected.to build_the_trio(peter, paul, nil) }
#     end

#     it_behaves_like 'rejecting semantically wrong arguments', :paul, :add_children

#     describe "paul.add_children(peter,steve)" do

#       subject { paul.add_children(peter,steve) }
      
#       context "when steve is valid" do
#         it { is_expected.to build_the_trio(peter, paul, nil) }
#         it { is_expected.to build_the_trio(steve, paul, nil) }
#       end

#       context "when steve is invalid" do
#         before { steve.mark_invalid! }
#         specify { expect { subject }.to raise_error }
#         describe "resulting trios" do
#           subject { paul.add_children(peter,steve) rescue true }
#           it { is_expected.to keep_the_trio(peter, nil, nil) }
#           it { is_expected.to keep_the_trio(steve, nil, nil) }
#         end
#       end

#     end

#     describe "paul.add_child(peter)" do
#       subject { paul.add_child(peter) }
#       it { is_expected.to build_the_trio(peter, paul, nil)}
#     end

#     context "when peter is an ancestor" do
#       before { paul.update_attribute(:father_id, peter.id) }
#       specify { expect { paul.add_children(peter) }.to raise_error(Genealogy::IncompatibleRelationshipException)}
#     end

#     context "when paul has undefined sex" do
#       before { paul.sex = nil }
#       specify { expect { paul.add_children(peter) }.to raise_error(Genealogy::SexError) }
#     end
    
#     describe "paul.add_children(julian, :spouse => michelle)" do
#       subject { paul.add_children(julian, :spouse => michelle) }
#       it { is_expected.to build_the_trio(julian, paul, michelle) }
#     end

#     describe "paul.add_children(peter, :spouse => john)" do 
#       specify { expect { paul.add_children(peter, :spouse => john) }.to raise_error(Genealogy::IncompatibleRelationshipException) }
#     end

#     context "when already has two children with titty (steve and peter) and one with michelle (julian) and a last one with an unknown spouse (ruben)" do
#       before {
#         peter.update_attributes(father_id: paul.id, mother_id: titty.id)
#         steve.update_attributes(father_id: paul.id, mother_id: titty.id)
#         julian.update_attributes(father_id: paul.id, mother_id: michelle.id)
#         ruben.update_attributes(father_id: paul.id)
#       }

#       describe "paul.remove_children" do
#         subject { paul.remove_children }
#         it { is_expected.to be true }
#         it { is_expected.to build_the_trio(peter, nil, titty) }
#         it { is_expected.to build_the_trio(steve, nil, titty) }
#         it { is_expected.to build_the_trio(julian, nil, michelle) }
#         it { is_expected.to build_the_trio(ruben, nil, nil) }
#         context "when steve is invalid" do
#           before { steve.mark_invalid! }
#           specify { expect { paul.remove_children }.to raise_error }
#           describe "resulting trios" do
#             subject { paul.remove_children rescue true }
#             it { is_expected.to keep_the_trio(peter, paul, titty) }
#             it { is_expected.to keep_the_trio(steve, paul, titty) }
#             it { is_expected.to keep_the_trio(julian, paul, michelle) }
#             it { is_expected.to keep_the_trio(ruben, paul, nil) }
#           end
#         end
#       end

#       describe "paul.remove_children(:affect_spouse => true)" do
#         subject { paul.remove_children(:affect_spouse => true) }
#         it { is_expected.to be true }
#         it { is_expected.to build_the_trio(peter, nil, nil) }
#         it { is_expected.to build_the_trio(steve, nil, nil) }
#         it { is_expected.to build_the_trio(julian, nil, nil) }
#         it { is_expected.to build_the_trio(ruben, nil, nil) }
#       end

#       describe "paul.remove_children(:spouse => titty)" do
#         subject { paul.remove_children(:spouse => titty) }
#         it { is_expected.to be true }
#         it { is_expected.to build_the_trio(peter, nil, titty) }
#         it { is_expected.to build_the_trio(steve, nil, titty) }
#         it { is_expected.to build_the_trio(julian, paul, michelle) }
#         it { is_expected.to build_the_trio(ruben, paul, nil) }
#       end

#       describe "paul.remove_children(:spouse => titty, :affect_spouse => true)" do
#         subject { paul.remove_children(:spouse => titty, :affect_spouse => true) }
#         it { is_expected.to be true }
#         it { is_expected.to build_the_trio(peter, nil, nil) }
#         it { is_expected.to build_the_trio(steve, nil, nil) }
#         it { is_expected.to build_the_trio(julian, paul, michelle) }
#         it { is_expected.to build_the_trio(ruben, paul, nil) }
#       end

#       describe "paul.remove_children(:spouse => maggie)" do
#         subject { paul.remove_children(:spouse => maggie) }
#         it { is_expected.to be false }
#         it { is_expected.to keep_the_trio(peter, paul, titty) }
#         it { is_expected.to keep_the_trio(steve, paul, titty) }
#         it { is_expected.to keep_the_trio(julian, paul, michelle) }
#         it { is_expected.to keep_the_trio(ruben, paul, nil) }
#       end

#       context "when specify a spouse with the same sex" do
#         describe "paul.remove_children(:spouse => john)" do
#           specify { expect { paul.remove_children(:spouse => john) }.to raise_error(Genealogy::SexError) }
#         end
#       end

#     end

#   end

#   context "when ignoring validation (options for has_parents: {:perform_validation => false})" do
#     before { @model = get_test_model({:perform_validation => false }) }

#     include_context 'unreleted people exist'

#     describe "paul.add_children(peter,steve)" do

#       subject { paul.add_children(peter,steve) }
      
#       context "when steve is invalid" do
#         before { steve.mark_invalid! }
#         specify { expect { subject }.to_not raise_error }
#         describe "resulting trios" do
#           subject { paul.add_children(peter,steve) }
#           it { is_expected.to keep_the_trio(peter, paul, nil) }
#           it { is_expected.to keep_the_trio(steve, paul, nil) }
#         end
#       end

#     end

#     context "when already has two children with titty (steve and peter) and one with michelle (julian) and a last one with an unknown spouse (ruben)" do
#       before {
#         peter.update_attributes(father_id: paul.id, mother_id: titty.id)
#         steve.update_attributes(father_id: paul.id, mother_id: titty.id)
#         julian.update_attributes(father_id: paul.id, mother_id: michelle.id)
#         ruben.update_attributes(father_id: paul.id)
#       }

#       describe "paul.remove_children" do
#         subject { paul.remove_children }
        
#         context "when steve is invalid" do
#           before { steve.mark_invalid! }
#           specify { expect { subject }.to_not raise_error }
#           it { is_expected.to build_the_trio(peter, nil, titty) }
#           it { is_expected.to build_the_trio(steve, nil, titty) }
#           it { is_expected.to build_the_trio(julian, nil, michelle) }
#           it { is_expected.to build_the_trio(ruben, nil, nil) }
#         end
#       end

#     end
#   end

# end
