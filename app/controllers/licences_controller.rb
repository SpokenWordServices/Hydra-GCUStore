class LicencesController < ApplicationController
	include HullAccessControlEnforcement

  before_filter :enforce_create_permissions

  def new
    @licence=Licence.new
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

end
