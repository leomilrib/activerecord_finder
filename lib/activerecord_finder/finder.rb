module ActiveRecordFinder
  class Finder
    attr_reader :table, :arel

    def initialize(arel_table, operation=nil)
      @table = arel_table
      @arel = operation
      @table.columns.each { |a| define_attribute_method a } rescue nil
    end

    def [](attribute)
      Comparator.new(self, @table[attribute])
    end

    def define_attribute_method(arel_attribute)
      singleton_class.send :define_method, arel_attribute.name do
        self[arel_attribute.name]
      end
    end
    private :define_attribute_method

    def |(other)
      other = other.arel if other.respond_to?(:arel)
      Finder.new(table, arel.or(other))
    end

    def &(other)
      other = other.arel if other.respond_to?(:arel)
      Finder.new(table, arel.and(other))
    end

    def !@
      Finder.new(table, Arel::Nodes::Not.new(arel))
    end

    undef_method :==

    def method_missing(method, *args, &b)
      super if args.size != 0 || b
      self[method]
    end
  end
end
