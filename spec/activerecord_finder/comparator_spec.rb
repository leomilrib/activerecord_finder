require_relative "../helper"

describe ActiveRecordFinder::Comparator do
  subject { ActiveRecordFinder::Comparator.new(finder, table[:name]) }
  let(:finder) { ActiveRecordFinder::Finder.new(table) }
  let(:table) { Person.arel_table }

  it 'should be able to find by equality' do
    (subject == 'foo').should be_a_kind_of(ActiveRecordFinder::Finder)
    (subject == 'foo').arel.should be_equivalent_to(table[:name].eq('foo'))
  end

  it 'should be able to find by inequality' do
    (subject != 'foo').arel.should be_equivalent_to(table[:name].not_eq('foo'))
  end

  it 'should be able to verify if an attribute is nil' do
    (subject.nil?).arel.should be_equivalent_to(table[:name].eq(nil))
  end

  it 'should be able to find by greater than' do
    (subject > 'foo').arel.should be_equivalent_to table[:name].gt('foo')
    (subject >= 'foo').arel.should be_equivalent_to table[:name].gteq('foo')
  end

  it 'should be able to find by lower than' do
    (subject < 'foo').arel.should be_equivalent_to table[:name].lt('foo')
    (subject <= 'foo').arel.should be_equivalent_to table[:name].lteq('foo')
  end

  it 'finds with IN' do
    subject.in?(['foo']).arel.should be_equivalent_to table[:name].in(['foo'])
  end

  it 'finds with NOT IN' do
    subject.not_in?(['foo']).arel.should be_equivalent_to table[:name].not_in(['foo'])
  end

  it 'finds with subselects' do
    result = subject.in?(Person.where(age: 10))
    result.arel.to_sql.should match(/select/i)
  end

  it 'should be able to find with LIKE' do
    (subject =~ 'foo').arel.should be_equivalent_to table[:name].matches('foo')
    (subject !~ 'foo').arel.should be_equivalent_to table[:name].does_not_match('foo')
  end

  it 'is able to find with COUNT' do
    (subject.size == 10).arel.should be_equivalent_to table[:name].count.eq(10)
  end
end
