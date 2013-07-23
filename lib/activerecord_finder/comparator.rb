module ActiveRecordFinder
  class Comparator
    attr_reader :field

    def initialize(finder, field)
      @finder = finder
      @field = field
    end

    def self.convert_to_arel(operation, arel_method)
      define_method(operation) do |other|
        other = other.field if other.respond_to?(:field)
        arel_clause =  @field.send(arel_method, other)
        Finder.new(@finder.table, arel_clause)
      end
    end

    def nil?
      self == nil
    end

    def in?(other)
      other = other.arel if other.respond_to?(:arel)
      arel_clause =  @field.in(other)
      Finder.new(@finder.table, arel_clause)
    end

    def not_in?(other)
      other = other.arel if other.respond_to?(:arel)
      arel_clause =  @field.not_in(other)
      Finder.new(@finder.table, arel_clause)
    end

    def size
      Comparator.new(@finder, @field.count)
    end
    alias :count :size

    def lower
      Comparator.new(@finder, @field.lower)
    end

    def upper
      Comparator.new(@finder, Arel::Nodes::NamedFunction.new("UPPER", [@field]))
    end

    convert_to_arel :==, :eq
    convert_to_arel '!=', :not_eq
    convert_to_arel :>, :gt
    convert_to_arel :>=, :gteq
    convert_to_arel :<, :lt
    convert_to_arel :<=, :lteq
    convert_to_arel :=~, :matches
    convert_to_arel '!~', :does_not_match
  end
end
