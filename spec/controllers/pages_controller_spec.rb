require 'rails_helper'


RSpec.describe PagesController, type: :controller do
  render_views
  describe "GET 'home'" do
    describe "quand pas identifié" do
      it "should be successful" do
        get 'home'
        expect(response).to be_success
      end

      it "devrait avoir le bon titre" do
        get 'home'
        expect(response.body).to have_title("Simple App du Tutoriel Ruby on Rails | Accueil")
      end
    end
    
    describe "quand identifié" do

      before(:each) do
        @user = test_sign_in(Factory(:user))
        other_user = Factory(:user, :email => Factory.next(:email))
        other_user.follow!(@user)
      end

      it "devrait avoir le bon compte d'auteurs et de lecteurs" do
        get :home
        expect(response.body).to have_selector("a[href='#{following_user_path(@user)}']",
                                           :text =>  "0 abonné")
        expect(response.body).to have_selector("a[href='#{followers_user_path(@user)}']",
                                           :text => "1 abonnement")
      end
    end
  end

  describe "GET 'contact'" do
    it "should be successful" do
      get 'contact'
      expect(response).to be_success
    end
    
    it "devrait avoir le bon titre" do
      get 'contact'
      expect(response.body).to have_title("Simple App du Tutoriel Ruby on Rails | Nous contacter")
    end
  end
  
   describe "GET 'about'" do
    it "should be successful" do
      get 'about'
      expect(response).to be_success
    end
    
    it "devrait avoir le bon titre" do
      get 'about'
     expect(response.body).to have_title("Simple App du Tutoriel Ruby on Rails | À propos")
    end
  end
  
  describe "GET 'help'" do
    it "should be successful" do
      get 'help'
      expect(response).to be_success
    end
    
    it "devrait avoir le bon titre" do
      get 'help'
     expect(response.body).to have_title("Simple App du Tutoriel Ruby on Rails | Aide")
    end
  end
  

end
