class SubjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_subject, only: %i[update destroy]

  # GET /subjects
  def index
    @subjects = current_user.subjects.all
    render json: SubjectSerializer.new(@subjects), status: :ok
  end

  # GET /subjects/find
  def show
    subject = current_user.subjects.find(params[:id])
    render json: SubjectSerializer.new(subject), status: :ok
  end

  # POST /subjects
  def create
    subject = current_user.subjects.new(subject_params)

    if subject.save
      render json: SubjectSerializer.new(subject), status: :created
    else
      render json: { error: subject.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /subjects/1
  def update
    # Now we update the subject with its new fields
    if @subject.update(subject_params)
      render json: SubjectSerializer.new(@subject), status: :ok
    else
      render json: { error: @subject.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /subjects/1
  def destroy
    if @subject.destroy
      render json: { message: "Subject deleted successfully" }, status: :ok
    else
      render json: { error: @subject.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  # Only parameters to be passed are name and description
  def subject_params
    params.require(:subject).permit(:id, :name, :description, :new_name)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_subject
    params.require(:subject).require(:id)
    @subject = current_user.subjects.find(subject_params[:id])  # No @subject_params

    unless @subject
      render json: { error: "Subject not found!" }, status: :not_found
    end
  end
end
