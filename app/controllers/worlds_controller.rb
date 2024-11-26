class WorldsController < ApplicationController
  before_action :set_current_user
  def new
    # Renders the character form
    @world_id = params[:world_id]
  end

  def index
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
    puts "Image path: #{@image_path.inspect}"

    @world = World.new(last_played: DateTime.now, progress: 0)
    if @world.save
      @world.update(world_name: "World #{@world.id}")
      UserWorld.create!(user: @current_user, world: @world, user_role: user_roles, owner: true)
      puts "hello World ID: #{@world.id.inspect}"
      Character.create!(world: @world, image_code: @image_path, shards: 10, x_coord: 0, y_coord: 0)
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

  def start_game
    puts 'params'
    puts params

    @new_world = @world.

    redirect_to some_other_path, notice: "Your adventure begins!"
  end
end