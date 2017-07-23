require "spec_helper"

describe ActiveRecordFinder::Comparator do
  subject { ActiveRecordFinder::Comparator.new(finder, table[:name]) }
  let(:finder) { ActiveRecordFinder::Finder.new(table) }
  let(:table) { Person.arel_table }

  it 'should be able to find by equality' do
    expect(subject == 'foo').to be_a_kind_of(ActiveRecordFinder::Finder)
    expect((subject == 'foo').arel).to be_equivalent_to(table[:name].eq('foo'))
  end

  it 'should be able to find by inequality' do
    expect((subject != 'foo').arel).to be_equivalent_to(table[:name].not_eq('foo'))
  end

  it 'should be able to verify if an attribute is nil' do
    expect((subject.nil?).arel).to be_equivalent_to(table[:name].eq(nil))
  end

  it 'should be able to find by greater than' do
    expect((subject > 'foo').arel).to be_equivalent_to table[:name].gt('foo')
    expect((subject >= 'foo').arel).to be_equivalent_to table[:name].gteq('foo')
  end

  it 'should be able to find by lower than' do
    expect((subject < 'foo').arel).to be_equivalent_to table[:name].lt('foo')
    expect((subject <= 'foo').arel).to be_equivalent_to table[:name].lteq('foo')
  end

  it 'finds with IN' do
    expect(subject.in?(['foo']).arel).to be_equivalent_to table[:name].in(['foo'])
  end

  it 'finds with NOT IN' do
    expect(subject.not_in?(['foo']).arel).to be_equivalent_to table[:name].not_in(['foo'])
  end

  it 'finds with subselects' do
    result = subject.in?(Person.where(age: 10))
    expect(result.arel.to_sql).to match(/select/i)
  end

  it 'should be able to find with LIKE' do
    expect((subject =~ 'foo').arel).to be_equivalent_to table[:name].matches('foo')
    expect((subject !~ 'foo').arel).to be_equivalent_to table[:name].does_not_match('foo')
  end

  it 'is able to find with COUNT' do
    expect((subject.size == 10).arel).to be_equivalent_to table[:name].count.eq(10)
  end

  it 'finds with LOWER or UPPER' do
    expect((subject.lower == "foo").arel).to be_equivalent_to table[:name].lower.eq('foo')
    expect((subject.upper == "foo").arel).to be_equivalent_to(
      Arel::Nodes::NamedFunction.new("UPPER", [table[:name]]).eq('foo')
    )
  end
end
