module ActiveRecordFinder
  module Where
    def where(*args, &block)
      args << nil if args.size == 0
      scoped = super
      return scoped if block.nil?

      from_block = super(new_finder(&block).arel) if block
      scoped.merge(from_block)
    end

    def new_finder(&block)
      arel_finder = ActiveRecordFinder::Finder.new(arel_table)
      if block.arity == 1
        block.call(arel_finder)
      else
        arel_finder.instance_eval(&block)
      end
    end
  end
end
