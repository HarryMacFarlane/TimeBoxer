class TagsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tag, only: %i[ update destroy ]

  # GET /tags
  def index
    @tags = current_user.tags.all

    unless @tags
      render json: {
        error: "Could not find any tags!"
      }, status: :not_found
    end

    render json: TagSerializer.new(@tags), status: :ok
  end

  # GET /tags/1
  def show
    tag = current_user.tags.find(params[:id])
    render json: TagSerializer.new(tag), status: :ok
  end

  # POST /tags
  def create
    tag = current_user.tags.new(tag_params)

    if tag.save
      render json: TagSerializer.new(tag), status: :created
    else
      render json: { error: tag.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /tags/1
  def update
    if @tag.update(tag_params)
      render json: TagSerializer.new(@tag), status: :ok
    else
      render json: @tag.errors, status: :unprocessable_entity
    end
  end

  # DELETE /tags/1
  def destroy
    if @tag.destroy!
      render status: :ok
    else
      render json: {
        error: "Could not delete tag: #{@tag.errors}"
      }, status: :unprocessable_entity
    end
  end

  private
    # Only allow a list of trusted parameters through.
    def tag_params
      params.require(:tag).permit(:id, :tag_name, :description, :color, :new_tag_name)
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_tag
      params.require(:tag).require(:id)
      @tag = current_user.tags.find(tag_params[:id])

      unless @tag
        render json: {
          error: "Could not find tag!"
        }, status: :not_found
      end
    end
end
