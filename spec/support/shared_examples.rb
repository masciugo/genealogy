shared_examples 'not accepting a semantically wrong argument' do |person,method,args|
  let(:p) { eval(person.to_s) }
  if args
    describe "#{person}.#{method}(#{args.join(', ')})" do
      specify { expect { p.send(method,*args.map{|i| eval(i.to_s)}) }.to raise_error }
    end
  else
    describe "#{person}.#{method}(#{person})" do
      specify { expect { p.send(method,p) }.to raise_error(Genealogy::IncompatibleRelationshipException) }
    end
    describe "#{person}.#{method}(Object.new)" do
      specify { expect { p.send(method,Object.new) }.to raise_error(ArgumentError) }
    end
  end
end

