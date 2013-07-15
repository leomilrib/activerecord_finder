require_relative "activerecord_finder/finder"
require_relative "activerecord_finder/comparator"
require_relative "activerecord_finder/where"
require_relative "activerecord_finder/set_operations"

ActiveRecord::Base.extend ActiveRecordFinder::Where
ActiveRecord::Relation.send :include, ActiveRecordFinder::SetOperations
