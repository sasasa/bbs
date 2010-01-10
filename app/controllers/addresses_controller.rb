class AddressesController < ApplicationController
  # 上書き 4 @user
  before_filter :check_valid_user

  # GET   /addresses
  def index
    @addresses = Address.paginate(:page => params[:page], :per_page => 50)
    @address = Address.new
  end

  # GET   /addresses/search
  # POST   /addresses/search
  def search
    @addresses = Address.find_by_address(params[:address])
  end

  # GET   /addresses/search_zip_code
  # POST   /addresses/search_zip_code
  def search_zip_code
    @addresses = Address.find_by_zip_code(params[:address][:zip_code])
  end

  # GET   /addresses/search_select
  # POST   /addresses/search_select
  def search_select
    @address = Address.find(params[:address][:town])
  end

  # POST   /addresses/districts
  def districts
    raise unless request.xhr?
    logger.debug "call districts ajax!! prefecture is " + params[:prefecture]
    @districts = Address.districts(params[:prefecture])
    render :layout=>nil
  end

  # POST   /addresses/towns
  def towns
    raise unless request.xhr?
    logger.debug "call towns ajax!! prefecture is " + params[:prefecture] + " district is " + params[:district]
    @towns = Address.towns(params[:prefecture], params[:district])
    render :layout=>nil
  end

  def auto_comp
    raise unless request.xhr?
    respond_to do |format|
      format.json { render :json => Address.find_by_zip_code_auto_compate(params[:address][:zip_code]) }
    end
  end
protected
  # 4 @user
  def check_valid_user
    logger.debug "filter4 check_valid_user => @user"
  end
  memoize :check_valid_user
end
