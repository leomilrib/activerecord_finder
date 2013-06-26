Arel Finders
============

The problem with ActiveRecord today is that there is no way to
construct queries outside "attribute = value" or using "OR" operator.
The solutions so far are not so easy to do, and usualy involves creating
fragments of SQL in string form.

But we have Arel. So, this must be solved, right?

Unfortunately, no. Arel's API is quite dificult to use, and its API is quite
inconsistent and changes over time, resulting in difficult code to mantain.

## ActiveRecord::Finder

So, the solution was to create an object, an "adapter-kind" of object.
ActiveRecord::Finder is a kind of object that contains all attributes
from a table, and allows you to `OR` or `AND` queries.

```ruby
finder = ActiveRecord::Finder.new(Arel::Table.new(:users))
query = finder.age > 10 | finder.name == "Foo"
query.arel.to_sql
#Returns: users.age > 10 OR users.name = 'Foo'
```

But it is kind of tedious to do this everytime you want to search for users,
so you can use ActiveRecord::Base#restrict with a block to construct your queries.

## ActiveRecord's Finders

Integrating with ActiveRecord, it is possible to use `restrict` to find records on a ActiveRecord object. The syntax is quite simple:

```ruby
User.restrict { |f| f.age > 18 }
#or
User.restrict { age > 18 }
```

ANDs work on the same way, too:

```ruby
User.restrict { age > 18 & age < 20 }
``` 

### All finders, so far:

```ruby
#WHERE NOT (users.age < 10)
User.restrict { !(age < 10) }

#Comparission
User.restrict { age == 20 }
User.restrict { age >= 20 }
User.restrict { age <= 20 }
User.restrict { age != 20 }
User.restrict { age > 20 }
User.restrict { age < 20 }

#IN
User.restrict { age.in?([10, 20, 30]) }

#LIKE
User.restrict { name =~ "Foo%" }
User.restrict { name !~ "Foo%" }

#AND, and OR
User.restrict { (name == "Foo") & (age < 20) }
User.restrict { (name == "Foo") | (age < 30) }
User.restrict do 
  ( (name == "Foo") & (age < 20) ) |
  ( (name == "Bar") | (age > 20) )
end
```

Plase note that because of operator precedence in Ruby, we must add a parenthesis over the comparission before using `&` or `|`.

## Constructing Queries

To avoid "merging" ActiveRecord::Relation's, there is a specific syntax to construct a complex query on ActiveRecord::Finder.

```ruby
def search(name_to_search, params = {})
  query = User.new_finder { name == name_to_search }
  query = query & User.new_finder { age > params[:age] } if params.include?(:age)
  query = query | User.new_finder { age <= 10 } if params[:include_all_childs]
  User.restrict(query)
end
```

### Using "joins"

To be simple, the `Finder` simply has the attributes from the table that it was created. So, to be able to find a record using attributes from one of the joined tables, it is possible to use `ActiveRecord::Base#merge` 

##