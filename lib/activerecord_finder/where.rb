module ActiveRecordFinder
  module Where
    def restrict(finder = nil, &block)
      raise ArgumentError, 'wrong number of arguments (0 for 1)' if block.nil? && finder.nil?
      if block
        where(create_finder(&block).arel)
      else
        where(finder.arel)
      end
    end
    alias :condition :restrict

    def restrict_with(*tables, &block)
      where(create_finder(*tables, &block).arel)
    end

    def new_finder(&block)
      new_finder_with(&block)
    end
    alias :to_finder :new_finder

    def new_finder_with(*tables, &block)
      scoped_where = all.arel.where_sql.map { |w| Arel.sql(w) }
      if block
        finder = create_finder(*tables, &block)
        scoped_where << finder.arel
      end
      arel = Arel::Nodes::And.new(scoped_where)
      ActiveRecordFinder::Finder.new(arel_table, arel)
    end
    alias :to_finder_with :new_finder_with


    def create_finder(*tables, &block)
      activerecord_finder = ActiveRecordFinder::Finder.new(arel_table)
      if tables.size == 0 && block.arity == 0
        activerecord_finder.instance_eval(&block)
      else
        additional_finders = tables.map do |table_name|
          arel_table = Arel::Table.new(table_name)
          ActiveRecordFinder::Finder.new(arel_table)
        end
        block.call(activerecord_finder, *additional_finders)
      end
    end
    private :create_finder
  end
end
