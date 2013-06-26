require_relative "activerecord_finder/finder"
require_relative "activerecord_finder/comparator"
require_relative "activerecord_finder/where"

ActiveRecord::Base.extend ActiveRecordFinder::Where
