require 'test_helper'

class CompanyInformationsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:company_informations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create company_information" do
    assert_difference('CompanyInformation.count') do
      post :create, :company_information => { }
    end

    assert_redirected_to company_information_path(assigns(:company_information))
  end

  test "should show company_information" do
    get :show, :id => company_informations(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => company_informations(:one).to_param
    assert_response :success
  end

  test "should update company_information" do
    put :update, :id => company_informations(:one).to_param, :company_information => { }
    assert_redirected_to company_information_path(assigns(:company_information))
  end

  test "should destroy company_information" do
    assert_difference('CompanyInformation.count', -1) do
      delete :destroy, :id => company_informations(:one).to_param
    end

    assert_redirected_to company_informations_path
  end
end
