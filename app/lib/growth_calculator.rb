class GrowthCalculator
  def initialize(values, position)
    @values = values
    @position = position
  end

  def call
    previous, current = values[position-1..position]

    return nil if current == 0

    growth = (current - previous).to_f / previous
    growth = nil if growth.infinite?
    growth
  end

  private

    attr_reader :values, :position
end
