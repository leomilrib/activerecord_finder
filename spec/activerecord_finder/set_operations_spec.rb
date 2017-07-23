require "spec_helper"

describe ActiveRecordFinder::SetOperations do
  let!(:seventeen) { Person.create! :name => 'Foo', :age => 17 }
  let!(:eighteen) { Person.create! :name => 'Foo', :age => 18 }

  it 'UNIONs two relations' do
    relation1 = Person.where(age: 17)
    relation2 = Person.where(age: 18)
    expect(relation1.unite_with(relation2)).to include(seventeen, eighteen)
  end

  it 'UNIONs two relations with JOIN' do
    seventeen_with_join = Person.create!(age: 17)
    seventeen_with_join.addresses.create!
    relation1 = Person.where(age: 17).joins(:addresses)
    relation2 = Person.where(age: 18)

    result = relation1.unite_with(relation2)
    expect(result).to include(seventeen_with_join, eighteen)
    expect(result).not_to include(seventeen)
  end

  it 'INTERSECTs two relations' do
    bar = Person.create!(name: "Bar", age: 17)
    relation1 = Person.where(age: 17)
    relation2 = Person.where(name: "Foo")
    expect(relation1.intersect_with(relation2)).to eq([seventeen])
  end

  it 'INTERSECTs two relations using another fields and another tables' do
    seventeen_bar = Person.create!(name: "Bar", age: 17)
    relation1 = Person.where(age: 17)
    relation2 = Person.where(name: "Foo")
    expect(relation1.intersect_with(relation2, :age)).to include(seventeen_bar, seventeen)
    expect(relation1.intersect_with(relation2, :age)).not_to include(eighteen)
  end

  it 'SUBTRACTs a relation from this one' do
    relation1 = Person.where(name: "Foo")
    relation2 = Person.where(age: 18)
    expect(relation1.subtract(relation2)).to eq([seventeen])
  end

  it 'SUBTRACTs a relation from this one, using another fields' do
    bar = Person.create! name: "Bar", age: 17
    Address.create! address: "Foo"

    relation1 = Person.where(age: 17)
    relation2 = Address.where(address: "Foo")

    expect(relation1.subtract(relation2, :name, :address)).to eq([bar])
  end
end
