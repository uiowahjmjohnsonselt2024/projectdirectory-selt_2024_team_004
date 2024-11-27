class SquaresController < ApplicationController
  def landing
    @squares = Square.all
    # generate_squares_if_needed
  end

  private

  # def generate_squares_if_needed
  #   (1..36).each do |i|
  #     Square.find_or_create_by(id: i) do |square|
  #       square.x = (i % 6) + 1  # Example x-coordinate
  #       square.y = (i / 6) + 1  # Example y-coordinate
  #       square.state = "inactive"
  #       square.pixel_art ||= generate_default_pixel_art(i)
  #     end
  #   end
  # end

  # def generate_default_pixel_art(id)
  #   # Example default 6x6 pixel art with '~' for water
  #   Array.new(6) { Array.new(6) { '~' }.join }.join("\n")
  # end
end
