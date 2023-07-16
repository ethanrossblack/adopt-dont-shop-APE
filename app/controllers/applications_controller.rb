class ApplicationsController < ApplicationController
  def index
    @application = Application.all
  end
  
  def show
    @application = Application.find(params[:id])
  end

  def new
    
  end

  def create
    application = Application.new(application_params)
    if application.save
      redirect_to "/applications/#{application.id}"
    else
      redirect_to "/applications/new"
      flash[:alert] = "Error: #{error_message(application.errors)}"
    end
  end

  private 
  def application_params
    params.permit(:name, :street, :city, :state, :zip, :description, :status)
  end
end
