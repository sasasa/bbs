require 'test_helper'

class CompanyTmpInformationsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:company_tmp_informations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create company_tmp_information" do
    assert_difference('CompanyTmpInformation.count') do
      post :create, :company_tmp_information => { }
    end

    assert_redirected_to company_tmp_information_path(assigns(:company_tmp_information))
  end

  test "should show company_tmp_information" do
    get :show, :id => company_tmp_informations(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => company_tmp_informations(:one).to_param
    assert_response :success
  end

  test "should update company_tmp_information" do
    put :update, :id => company_tmp_informations(:one).to_param, :company_tmp_information => { }
    assert_redirected_to company_tmp_information_path(assigns(:company_tmp_information))
  end

  test "should destroy company_tmp_information" do
    assert_difference('CompanyTmpInformation.count', -1) do
      delete :destroy, :id => company_tmp_informations(:one).to_param
    end

    assert_redirected_to company_tmp_informations_path
  end
end
