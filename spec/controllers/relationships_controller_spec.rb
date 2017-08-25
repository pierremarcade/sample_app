require 'rails_helper'

RSpec.describe RelationshipsController, type: :controller do
  render_views
  describe "Le contrôle d'accès" do

    it "devrait exiger l'identification pour créer" do
      post :create
      expect(response).to redirect_to(signin_path)
    end

    it "devrait exiger l'identification pour détruire" do
      delete :destroy, params: {:id => 1}
      expect(response).to redirect_to(signin_path)
    end
  end

  describe "POST 'create'" do

    before(:each) do
      @user = test_sign_in(Factory(:user))
      @followed = Factory(:user, :email => Factory.next(:email))
    end

    it "devrait créer une relation" do
      expect(lambda do
        post :create, params: {:relationship => {:followed_id => @followed }}
        expect(response).to be_redirect
      end).to change(Relationship, :count).by(1)
    end
    
    it "devrait créer une relation en utilisant Ajax" do
      expect(lambda do
        post :create, params: {:relationship => { :followed_id => @followed } , format: :js}
        expect(response).to be_success
      end).to change(Relationship, :count).by(1)
    end
  end

  describe "DELETE 'destroy'" do

    before(:each) do
      @user = test_sign_in(Factory(:user))
      @followed = Factory(:user, :email => Factory.next(:email))
      @user.follow!(@followed)
      @relationship = @user.relationships.find_by_followed_id(@followed)
    end

    it "devrait détruire une relation" do
      expect(lambda do
        delete :destroy, params: {:id => @relationship}
        expect(response).to be_redirect
      end).to change(Relationship, :count).by(-1)
    end
    
    it "devrait détruire une relation en utilisant Ajax" do
      expect(lambda do
        delete :destroy, params: {:id => @relationship, format: :js}
        expect(response).to be_success
      end).to change(Relationship, :count).by(-1)
    end
  end
end
