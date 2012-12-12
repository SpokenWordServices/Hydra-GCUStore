class LicencesController < ApplicationController
	include HullAccessControlEnforcement

  before_filter :enforce_create_permissions
  before_filter :load_licence, :only => [:edit, :show, :update, :destroy] 

  def new
    @licence=Licence.new
  end

  def show
  end

  def index
    @licences= Licence.all
  end

	def create
		@licence =Licence.new(params[:licence])
		if @licence.save
		  redirect_to licences_path, :notice =>'New Licence Created!'
			
		else
			render :new, :notice => 'Failed to save'
		end
		
	end

  def edit
  end

  def update
    if @licence.update_attributes(params[:licence])
      redirect_to @licence, :notice => "Updated!"
    else 
      render :edit, :notice=> "Failed to update"
    end
  end

  def destroy
    if @licence.destroy
      redirect_to licences_path , :notice => "Licence was deleted!"
    else
      redirect_to licences_path , :notice => "Failed to delete!"
    end
  end 

private 
  def load_licence
    @licence=Licence.find(params[:id])
  end

end
