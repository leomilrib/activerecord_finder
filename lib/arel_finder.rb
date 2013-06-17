require_relative "arel_finder/finder"
require_relative "arel_finder/comparator"
require_relative "arel_finder/where"

ActiveRecord::Base.extend ArelFinder::Where
