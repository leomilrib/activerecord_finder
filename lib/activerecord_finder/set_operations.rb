module ActiveRecordFinder
  module SetOperations
    def unite_with(other)
      check_error(other)
      first_subselect = unscoped.where(primary_key => other)
      second_subselect = unscoped.where(primary_key => self)
      unscoped.restrict(first_subselect.to_finder | second_subselect.to_finder)
    end

    def intersect_with(other, field_self=nil, field_other=nil)
      field_other ||= field_self

      if field_self.nil?
        where(primary_key => other)
      else
        field = other.scoped.arel_table[field_other]
        where(field_self => other.select(field))
      end
    end

    def subtract(other)
      check_error(other)
      subselect = unscoped.where(primary_key => other)
      restrict(!subselect.to_finder)
    end

    def check_error(other)
      if arel_table.name != other.arel_table.name
        raise ArgumentError, "can't operate on different tables"
      elsif primary_key.nil?
        raise ArgumentError, "must have a primary key"
      end
    end
    private :check_error
  end
end
