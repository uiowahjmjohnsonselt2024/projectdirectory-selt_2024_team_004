class WorldsController < ApplicationController
  before_action :set_current_user
  def landing
    store
    @user_world = UserWorld.find_by(id: params[:id])
    @world = @user_world.world
    @character = @world.characters.first
    @character.x_coord ||= 0
    @character.y_coord ||= 27
  end
  
  def new
    # Renders the character form
    @world_id = params[:world_id]
  end

  def index
    #@worlds parameter will be a list of all the world keys the current user has
    puts params
    puts @current_user.name
    if @current_user
      @user_worlds = @current_user.user_worlds
    else
      flash[:alert] = "Please log in to view your worlds."
      redirect_to login_path
    end
  end

  def create
    puts "Form submitted successfully!"
    @world = World.new(last_played: DateTime.now, progress: 0)
    if @world.save
      @world.update(world_name: "World #{@world.id}")
      UserWorld.create!(user: @current_user, world: @world, user_role: user_roles, owner: true)
      Character.create!(world: @world, image_code: @image_path, shards: 10, x_coord: 10, y_coord: 10)
      flash[:notice] = "World created successfully!"
      redirect_to worlds_path
    end
  end

  def destroy
    @user_world = UserWorld.find_by(id: params[:id])
    @world = World.find_by(id: @user_world.world_id)
    if @user_world.owner
      UserWorld.where(world_id: @world.id).destroy_all
      @world.destroy
      flash[:notice] = "World '#{@world.world_id}' deleted."
    else
      @user_world.destroy
      flash[:notice] = "World '#{@world.world_id}' removed."
    end
    redirect_to worlds_path
  end

  def user_roles
    @gender = params[:gender]
    @preload = params[:preload]
    @role = params[:role]

    if @gender && @preload && @role
      @image_path = "#{@gender}_#{@preload}_#{@role}.png"
    else
      @image_path = "1_1_1.png"
    end
  end

  def store
    @user = current_user
    @currency = @user.default_currency || 'USD'
    @prices = StoreService.fetch_prices(@user)
  end

  def api_call
    client = OpenAI::Client.new(
      # change key
      access_token: "sk-proj-8eh6vdKNh6jedL0d1Wg8EMTjfdFnit-1mZdI_ydVA-uhaIMPLD3YCq5XLseNB13sfjBgNF3WcNT3BlbkFJLob1PGSBsnDW_HVzVI9UoAI8dT3nL61p1ujEbJfrTfKgw_u60T8B_k4Cr0-jCJ021",
      log_errors: true # Highly recommended in development, so you can see what errors OpenAI is returning. Not recommended in production because it could leak private data to your logs.
    )
  end

  def current_user
    @current_user ||= User.find_by id: params[:user_id]
  end
end