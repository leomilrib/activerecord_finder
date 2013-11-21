module ActiveRecordFinder
  module SetOperations
    def self.counter
      @counter ||= 0
      @counter = (@counter + 1) % 9_000
    end

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
      other_table = other.respond_to?(:arel) ? other.arel : other
      other_table = other_table.as("alias_#{SetOperations.counter}")

      field_other ||= field_self
      field_self ||= primary_key
      field_other ||= other.primary_key

      self_table = as(arel.froms[0].name)
      unscoped.from([self_table, other_table]).where(field_self => other_table[field_other])
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
