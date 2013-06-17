module ArelFinder
  module Where
    def where(*args, &block)
      if block
        from_block = super(new_finder(&block).arel) if block
        if args.size > 0
          from_block.where(*args)
        else
          from_block
        end
      else
        super
      end
    end

    def new_finder(&block)
      arel_finder = ArelFinder::Finder.new(arel_table)
      if block.arity == 1
        block.call(arel_finder)
      else
        arel_finder.instance_eval(&block)
      end
    end
  end
end
