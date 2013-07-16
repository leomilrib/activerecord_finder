module ActiveRecordFinder
  module SetOperations
    def unite_with(other)
      if arel_table.name != other.arel_table.name
        raise ArgumentError, "can't operate on different tables"
      elsif primary_key.nil?
        raise ArgumentError, "must have a primary key"
      end

      first_subselect = unscoped.where(primary_key => other)
      second_subselect = unscoped.where(primary_key => self)
      unscoped.restrict(first_subselect.to_finder | second_subselect.to_finder)
    end

    def intersect_with(other, field_self=nil, field_other=nil)
      field_other ||= field_self

      if field_self.nil?
        where(primary_key => other)
      else
        if field_other.is_a?(Symbol)
          field_other = other.scoped.arel_table[field_other]
        end
        where(field_self => other.select(field_other))
      end
    end

    def subtract(other, field_self=nil, field_other=nil)
      field_other ||= field_self

      if field_self.nil?
        subselect = unscoped.where(primary_key => other)
      else
        if field_other.is_a?(Symbol)
          field_other = other.scoped.arel_table[field_other]
        end
        subselect = unscoped.where(field_self => other.select(field_other))
      end
      restrict(!subselect.to_finder)
    end
  end
end
