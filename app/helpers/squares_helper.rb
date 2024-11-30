module SquaresHelper
    def pixel_class(char)
      case char
      when '~' then 'water'
      when '#' then 'land'
      when '.' then 'sand'
      else 'default'
      end
    end
  end  