require "spec_helper"

describe ActiveRecordFinder::Where do
  let!(:bar) { Person.create! :name => 'Bar', :age => 17 }
  let!(:seventeen) { Person.create! :name => 'Foo', :age => 17 }
  let!(:eighteen) { Person.create! :name => 'Foo', :age => 18 }

  after do
    Person.delete_all
  end

  it 'finds using a block with one parameter' do
    result = Person.restrict { |p| (p.name == 'Foo') & (p.age > 17) }
    expect(result).to eq([eighteen])
  end

  it 'finds using a block with no parameters' do
    result = Person.restrict { (name == 'Foo') & (age > 17) }
    expect(result).to eq([eighteen])
  end

  it 'concatenates conditions' do
    finder1 = Person.new_finder { age == 17 }
    finder2 = Person.new_finder { name == "Foo" }
    result = Person.restrict(finder1 & finder2)
    expect(result).to eq([seventeen])
  end

  it 'concatenates scoped conditions' do
    boo = Person.create!(name: "Boo", age: 17)
    person = Person.where(age: 17).where('name LIKE ?', 'B%')
    new_finder = person.new_finder { name == 'Boo' }
    result = Person.restrict(new_finder)
    expect(result).to eq([boo])
  end

  it 'creates a new finder without a block, using only current scope' do
    person = Person.where(age: 17).where('name LIKE ?', 'B%')
    new_finder = person.new_finder
    expect(Person.restrict(new_finder)).to eq([bar])
  end

  it 'finds using fields from other tables' do
    seventeen.addresses.create! address: "Seventeen Road"
    eighteen.addresses.create! address: "Eighteen Road"

    result = Person.joins(:addresses).restrict(
      Person.new_finder_with(:addresses) { |_, a| a.address =~ 'Eighteen%' })
    expect(result).to eq([eighteen])

    result = Person.joins(:addresses).restrict_with(:addresses) { |_, a| a.address =~ 'Seventeen%' }
    expect(result).to eq([seventeen])
  end

  it 'finds by multiple tables or aliases' do
    finder = Person.new_finder_with(:custom) { |p, c| p.id == c.id }

    people_table = Arel::Table.new(:people)
    custom_table = Arel::Table.new(:custom)
    expect(finder.arel).to be_equivalent_to(people_table[:id].eq(custom_table[:id]))
  end
end
