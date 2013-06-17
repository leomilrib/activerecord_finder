module ArelFinder
  class Comparator
    def initialize(finder, field)
      @finder = finder
      @field = field
    end

    def self.convert_to_arel(operation, arel_method)
      define_method(operation) do |other|
        arel_clause =  @field.send(arel_method, other)
        Finder.new(@finder.table, arel_clause)
      end
    end

    def nil?
      self == nil
    end

    convert_to_arel :==, :eq
    convert_to_arel '!=', :not_eq
    convert_to_arel :>, :gt
    convert_to_arel :>=, :gteq
    convert_to_arel :<, :lt
    convert_to_arel :<=, :lteq
    convert_to_arel :in?, :in
    convert_to_arel :=~, :matches
    convert_to_arel '!~', :does_not_match
  end
end
