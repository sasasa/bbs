class CompanyInformationsController < ApplicationController
  # GET /company_informations
  def index
    @company_informations = CompanyInformation.all
  end

  # GET /company_informations/1
  def show
    @company_information = CompanyInformation.find(params[:id])
  end

  # GET /company_informations/new
  def new
    @company_information = CompanyInformation.new.init_photos
  end

  # GET /company_informations/1/edit
  def edit
    @company_information = CompanyInformation.find(params[:id]).init_photos
  end

  # POST /company_informations
  def create
    @company_information = CompanyInformation.new(params[:company_information])

    if @company_information.save
      flash[:notice] = 'CompanyInformation was successfully created.'
      redirect_to(@company_information)
    else
      @company_information.init_photos
      render "new"
    end
  end

  # PUT /company_informations/1
  def update
    @company_information = CompanyInformation.find(params[:id])

    if @company_information.update_attributes(params[:company_information])
      flash[:notice] = 'CompanyInformation was successfully updated.'
      redirect_to(@company_information)
    else
      @company_information.init_photos
      render "edit"
    end
  end

  # DELETE /company_informations/1
  def destroy
    @company_information = CompanyInformation.find(params[:id])
    @company_information.destroy

    redirect_to(company_informations_url)
  end

  protected
  # 4
  def check_valid_user
    logger.debug "filter4 check_valid_user"
  end
end
