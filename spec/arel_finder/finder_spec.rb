require_relative "../helper"

describe ArelFinder::Finder do
  subject { ArelFinder::Finder.new(table) }
  let(:table) { Person.arel_table }

  it 'should return a empty arel if not being able to convert' do
    subject.arel.should be_nil
  end

  it 'should not calculate equality' do
    proc { subject == subject }.should raise_error(NoMethodError)
    proc { subject != subject }.should raise_error(NoMethodError)
  end

  it 'should be able to "or" two conditions' do
    c1 = table[:id].eq(1)
    c2 = table[:name].eq(2)
    ((subject.id == 1) | (subject.name == 2)).arel.should be_equivalent_to c1.or(c2)
  end

  it 'should be able to "and" two conditions' do
    c1 = table[:id].eq(1)
    c2 = table[:name].eq(2)
    ((subject.id == 1) & (subject.name == 2)).arel.should be_equivalent_to c1.and(c2)
  end

  it 'should be able to negate the find' do
    result = subject.name == 'foo'
    (!result).arel.should be_equivalent_to Arel::Nodes::Not.new(table[:name].eq('foo'))
  end
end
