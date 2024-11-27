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

        def api_call
          client = OpenAI::Client.new(
            # change key
            access_token: "sk-proj-8eh6vdKNh6jedL0d1Wg8EMTjfdFnit-1mZdI_ydVA-uhaIMPLD3YCq5XLseNB13sfjBgNF3WcNT3BlbkFJLob1PGSBsnDW_HVzVI9UoAI8dT3nL61p1ujEbJfrTfKgw_u60T8B_k4Cr0-jCJ021",
            log_errors: true # Highly recommended in development, so you can see what errors OpenAI is returning. Not recommended in production because it could leak private data to your logs.
          )
        end
        
      end      
end
