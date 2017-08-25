require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  render_views
  describe "GET #new" do
    it "devrait réussir" do
      get :new
      expect(response).to have_http_status(:success)
    end
    
    it "devrait avoir le bon titre" do
      get :new
      expect(response.body).to have_title("Simple App du Tutoriel Ruby on Rails | S'identifier")
    end
  end

  describe "POST 'create'" do

    describe "invalid signin" do

      before(:each) do
        @attr = { :email => "email@example.com", :password => "invalid" }
      end

      it "devrait re-rendre la page new" do
        post :create, params: {:session => @attr}
        expect(response).to render_template('new')
      end

      it "devrait avoir le bon titre" do
        post :create, params: {:session => @attr}
        expect(response.body).to have_title("Simple App du Tutoriel Ruby on Rails | S'identifier")
      end

      it "devait avoir un message flash.now" do
        post :create, params: {:session => @attr}
        expect(flash.now[:error]).to be_present
      end
    end
    
    describe "avec un email et un mot de passe valides" do

      before(:each) do
        @user = Factory(:user)
        @attr = { :email => @user.email, :password => @user.password }
      end

      it "devrait identifier l'utilisateur" do
        post :create, params: {:session => @attr}
        expect(controller.current_user).to eq(@user)
        expect(controller).to be_signed_in
      end

      it "devrait rediriger vers la page d'affichage de l'utilisateur" do
        post :create, params: {:session => @attr}
        expect(response).to redirect_to(user_path(@user))
      end
    end
  end
  
  describe "DELETE 'destroy'" do

    it "devrait déconnecter un utilisateur" do
      test_sign_in(Factory(:user))
      delete :destroy
      expect(controller).to_not be_signed_in
      expect(response).to redirect_to(root_path)
    end
  end
end
