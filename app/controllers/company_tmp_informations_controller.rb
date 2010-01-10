class CompanyTmpInformationsController < ApplicationController
  # GET /company_tmp_informations
  def index
    @company_tmp_informations = CompanyTmpInformation.all
  end

  # GET /company_tmp_informations/1
  def show
    @company_tmp_information = CompanyTmpInformation.find(params[:id])
  end

  # GET /company_tmp_informations/new
  def new
    @company_tmp_information = CompanyTmpInformation.new.init_photos
  end

  # GET /company_tmp_informations/1/edit
  def edit
    @company_tmp_information = CompanyTmpInformation.find(params[:id]).init_photos
  end

  # POST /company_tmp_informations
  def create
    @company_tmp_information = CompanyTmpInformation.new(params[:company_tmp_information])

    if @company_tmp_information.save
      flash[:notice] = 'CompanyTmpInformation was successfully created.'
      redirect_to(@company_tmp_information)
    else
      @company_tmp_information.init_photos
      render "new"
    end
  end

  # PUT /company_tmp_informations/1
  def update
    @company_tmp_information = CompanyTmpInformation.find(params[:id])

    if @company_tmp_information.update_attributes(params[:company_tmp_information])
      flash[:notice] = 'CompanyTmpInformation was successfully updated.'
      redirect_to(@company_tmp_information)
    else
      @company_tmp_information.init_photos
      render "edit"
    end
  end

  # DELETE /company_tmp_informations/1
  def destroy
    @company_tmp_information = CompanyTmpInformation.find(params[:id])
    @company_tmp_information.destroy

    redirect_to(company_tmp_informations_url)
  end

  protected
  # 4
  def check_valid_user
    logger.debug "filter4 check_valid_user"
  end
end
