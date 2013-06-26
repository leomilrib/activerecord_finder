require_relative "../helper"

describe ActiveRecordFinder::Where do
  let!(:bar) { Person.create! :name => 'Bar', :age => 17 }
  let!(:seventeen) { Person.create! :name => 'Foo', :age => 17 }
  let!(:eighteen) { Person.create! :name => 'Foo', :age => 18 }

  after do
    Person.delete_all
  end

  it 'finds using a block with one parameter' do
    result = Person.where { |p| (p.name == 'Foo') & (p.age > 17) }
    result.should == [eighteen]
  end

  it 'finds using a block with no parameters' do
    result = Person.where { (name == 'Foo') & (age > 17) }
    result.should == [eighteen]
  end

  it 'finds using a condition too' do
    result = Person.where(:age => 17) { name == 'Foo' }
    result.should == [seventeen]
  end

  it 'concatenates conditions' do
    finder1 = Person.new_finder { age == 17 }
    finder2 = Person.new_finder { name == "Foo" }
    result = Person.where((finder1 & finder2).arel)
    result.should == [seventeen]
  end

  it 'concatenates arel conditions' do
    finder1 = Person.where(name: "Foo").arel
    finder2 = Person.new_finder { age == 17 }
    result = Person.where((finder2 & finder1).arel)
    result.should == [seventeen]
    result = Person.where((finder1 & finder2).arel)
    result.should == [seventeen]
  end
end
