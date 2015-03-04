def trio_to_s(c,f,m)
  "[ #{c} | #{f or 'UNDEFINED'} | #{m or 'UNDEFINED'} ]"
end


# trio matchers
RSpec::Matchers.define :build_the_trio do |child, father, mother|
  child.reload
  match do
    child.father == father and child.mother == mother
  end
  description do
    "build the expected trio"
  end
  failure_message do
    <<-MSG
expected: #{trio_to_s(child, father, mother)}
     got: #{trio_to_s(child, child.father, child.mother)}
MSG
  end
  failure_message_when_negated do
    "got: #{trio_to_s(child, child.father, child.mother)}"
  end
end
RSpec::Matchers.alias_matcher :keep_the_trio, :build_the_trio do |description|
  description.sub("build", "keep")
end
RSpec::Matchers.define :be_a_trio do
  child = nil
  father = nil
  mother = nil
  match do |trio|
    child, father, mother = trio
    child.reload
    child.father == father and child.mother == mother
  end
  failure_message do
    <<-MSG
expected: #{trio_to_s(*trio)}
     got: #{trio_to_s(child, child.father, child.mother)}
MSG
  end
  failure_message_when_negated do
    "got: #{trio_to_s(child, child.father, child.mother)}"
  end
end

# siblings matchers
RSpec::Matchers.define :be_siblings do
  match do |siblings|
    fathers = siblings.map{|s| s.reload.father}
    mothers = siblings.map{|s| s.reload.mother}
    fathers.uniq.count == 1 and mothers.uniq.count == 1
  end
end
RSpec::Matchers.define :be_paternal_half_siblings do
  match do |siblings|
    fathers = siblings.map{|s| s.reload.father}
    fathers.uniq.count == 1
  end
end
RSpec::Matchers.define :be_maternal_half_siblings do
  match do |siblings|
    mothers = siblings.map{|s| s.reload.mother}
    mothers.uniq.count == 1
  end
end



# couple matchers
RSpec::Matchers.define :build_the_couple do |spouse1, spouse2|
  spouse1.reload
  spouse2.reload
  match do 
    spouse1.current_spouse == spouse2 and spouse2.current_spouse == spouse1
  end
  description do
    "build the couple: #{spouse1} - #{spouse2}"
  end
  failure_message do
    <<-MSG
expected spouse of #{spouse1} was #{spouse2}, got #{spouse1.current_spouse}
expected spouse of #{spouse2} was #{spouse1}, got #{spouse2.current_spouse}
MSG
  end
  failure_message_when_negated do
    <<-MSG
expected spouse of #{spouse1} was #{spouse1.current_spouse}
expected spouse of #{spouse2} was #{spouse2.current_spouse}
MSG
  end
end
RSpec::Matchers.alias_matcher :keep_the_couple, :build_the_couple do |description|
  description.sub("build", "keep")
end
RSpec::Matchers.define :be_a_couple do
  spouse1 = nil
  spouse2 = nil
  match do |spouses|
    spouse1 = spouses.first.reload
    spouse2 = spouses.last.reload
    spouse1.current_spouse == spouse2 and spouse2.current_spouse == spouse1
  end
  failure_message do
    <<-MSG
expected spouse of #{spouse1} was #{spouse2}, got #{spouse1.current_spouse}
expected spouse of #{spouse2} was #{spouse1}, got #{spouse2.current_spouse}
MSG
  end
  failure_message_when_negated do
    "#{spouse1} and #{spouse2} are a couple"
  end
end
RSpec::Matchers.define :be_single do
  match do |person|
    person.reload.current_spouse.nil?
  end
end


# family matcher
RSpec::Matchers.define :match_family do |hash|
  res = nil
  match do
    hash.keys.sort == actual.keys.sort and
    hash.keys.inject(true){|tot,k| hash[k].is_a?(Array) ? (hash[k].sort == actual[k].sort) : (hash[k] == actual[k])} 
  end
  description do
    "has the family #{actual}"
  end
  failure_message do
    <<-MSG
expected: #{hash}
     got: #{actual}
MSG
  end
end



