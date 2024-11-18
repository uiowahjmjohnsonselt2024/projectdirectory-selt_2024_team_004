class WorldsController < ApplicationController
  before_action :set_current_user
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
      flash[:notice] = "World created successfully!"
      redirect_to worlds_path
    end
  end

  def destroy
    puts params.inspect
    puts "UserWorld: #{@user_world.inspect}"
    @user_world = UserWorld.find_by(id: params[:id])
    puts @user_world
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

  #Might be able to combined these three
  def user_roles
    @gender = params[:gender]
    @preload = params[:preload]
    @role = params[:role]
    
    if @gender && @preload && @role
      @image_key = "#{@gender}_#{@preload}_#{@role}"
      @image_path = "images/#{@image_key}.jpg"
    end
  end

  def start_game
    puts 'params'
    puts params

    @new_world = @world.

    redirect_to some_other_path, notice: "Your adventure begins!"
  end

  def api_call
    client = OpenAI::Client.new(
      access_token: "access_token_goes_here",
      log_errors: true # Highly recommended in development, so you can see what errors OpenAI is returning. Not recommended in production because it could leak private data to your logs.
    )
  end
end