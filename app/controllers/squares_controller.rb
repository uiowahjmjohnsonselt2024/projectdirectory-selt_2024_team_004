class SquaresController < ApplicationController
    class SquaresController < ApplicationController
        def index
          @squares = Square.all
        end
      
        def update
          @square = Square.find(params[:id])
          if @square.update(square_params)
            render json: @square, status: :ok
          else
            render json: { error: @square.errors.full_messages }, status: :unprocessable_entity
          end
        end
      
        private
      
        def square_params
          params.require(:square).permit(:x, :y, :weather, :treasure, :game, :monsters)
        end
      end      
end
