require "sqlite3"
require "active_record"
require_relative "../lib/activerecord_finder"

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

ActiveRecord::Base.connection.execute(<<-SQL)
  CREATE TABLE people(id integer primary key, name varchar(255), age INTEGER)
SQL
ActiveRecord::Base.connection.execute(<<-SQL)
  CREATE TABLE addresses(id integer primary key, address varchar(255), person_id integer)
SQL

class Person < ActiveRecord::Base
  has_many :addresses
end

class Address < ActiveRecord::Base
  belongs_to :person
end

RSpec.configure do |c|
  c.after do
    Address.delete_all
    Person.delete_all
  end
end

RSpec::Matchers.define :be_equivalent_to do |arel|
  match do |match|
    arel.to_sql == match.to_sql
  end

  failure_message_for_should do |match|
    <<~MSG
      The two AREL objects are not equivalent.
      First is:
        #{match.to_sql}
      Second is:
        #{arel.to_sql}
    MSG
  end
end
