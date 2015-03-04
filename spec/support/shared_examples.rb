shared_examples 'raising error because of semantically wrong argument' do |person,method|
  let(:p) { eval(person.to_s) }
  context "when passing theirself" do
    specify { expect { p.send(method,p) }.to raise_error(Genealogy::IncompatibleRelationshipException) }
  end
  context "when passing a generic object" do
    specify { expect { p.send(method,Object.new) }.to raise_error(ArgumentError) }
  end
end

shared_examples 'removing the relative' do |person,role|
  let(:p) { eval(person.to_s) }
  it { is_expected.to be true }
  it "receiver has not #{role} anymore" do
    subject
    expect(p.send(role)).to be nil
  end
end