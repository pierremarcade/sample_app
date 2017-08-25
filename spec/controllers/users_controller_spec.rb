require 'rails_helper'


RSpec.describe UsersController, type: :controller do
  render_views
  
  describe "GET 'index'" do

    describe "pour utilisateur non identifiés" do
      it "devrait refuser l'accès" do
        get :index
        expect(response).to redirect_to(signin_path)
        expect(flash[:notice]).to be_present
      end
    end

    describe "pour un utilisateur identifié" do

      before(:each) do
        @user = test_sign_in(Factory(:user))
        second = Factory(:user, :email => "another@example.com")
        third  = Factory(:user, :email => "another@example.net")

        @users = [@user, second, third]
        30.times do
          @users << Factory(:user, :email => Factory.next(:email))
        end
      end

      it "devrait réussir" do
        get :index
        expect(response).to be_success
      end

      it "devrait avoir le bon titre" do
        get :index
        expect(response.body).to have_title("Simple App du Tutoriel Ruby on Rails | Tous les utilisateurs")
      end

      it "devrait avoir un élément pour chaque utilisateur" do
        get :index
        @users.each do |user|
          expect(response.body).to have_selector("li", :text => user.name)
        end
      end
      
      it "devrait avoir un élément pour chaque utilisateur" do
        get :index
        @users[0..2].each do |user|
          expect(response.body).to have_selector("li", :text => user.name)
        end
      end

      it "devrait paginer les utilisateurs" do
        get :index
        expect(response.body).to have_selector("div.pagination")
        expect(response.body).to have_selector("span.disabled", :text => "Précédent")
        expect(response.body).to have_selector("a[href='/users?page=2']",
                                           :text => "2")
        expect(response.body).to have_selector("a[href='/users?page=2']",
                                           :text => "Suivant")
      end
    end
  end
  
  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      expect(response).to be_success
    end
    
    it "devrait avoir le bon titre" do
      get 'new'
     expect(response.body).to have_title("Simple App du Tutoriel Ruby on Rails | Inscription")
    end
  end
  
  describe "GET 'show'" do

    before(:each) do
      test_sign_in(@user =Factory(:user))
      
    end

    it "devrait réussir" do
      get :show, params: {:id => @user}
       expect(response).to be_success
    end

    it "devrait trouver le bon utilisateur" do
      get :show, params: {:id => @user}
      expect(assigns(:user)).to eq(@user)
    end
    
    it "devrait avoir le bon titre" do
      get :show,  params: {:id => @user}
      expect(response.body).to have_title("Simple App du Tutoriel Ruby on Rails | " + "#{@user.name}")
    end

    it "devrait inclure le nom de l'utilisateur" do
      get :show,  params: {:id => @user}
      expect(response.body).to have_selector("h1", :text => @user.name)
    end

    it "devrait avoir une image de profil" do
      get :show,  params: {:id => @user}
      expect(response.body).to have_selector("img", :class => "gravatar")
    end
    
    it "devrait afficher les micro-messages de l'utilisateur" do
      mp1 = Factory(:micropost, :user => @user, :content => "Foo bar")
      mp2 = Factory(:micropost, :user => @user, :content => "Baz quux")
      get :show, params: {:id => @user}
      expect(response.body).to have_selector("span.content", :text => mp1.content)
      expect(response.body).to have_selector("span.content", :text => mp2.content)
    end

  end
  
  describe "POST 'create'" do

    describe "échec" do

      before(:each) do
        @attr = { :name => "", :email => "", :password => "",
                  :password_confirmation => "" }
      end

      it "ne devrait pas créer d'utilisateur" do
        expect(lambda do
          post :create, params: {:user => @attr}
        end).to_not change(User, :count)
      end

      it "devrait avoir le bon titre" do
        post :create, params: {:user => @attr}
        expect(response.body).to have_title("Simple App du Tutoriel Ruby on Rails | Inscription")
      end

      it "devrait rendre la page 'new'" do
        post :create, params: {:user => @attr}
        expect(response).to render_template('new')
      end
    end
    
    
    describe "succès" do

      before(:each) do
        @attr = { :name => "New User", :email => "user@example.com",
                  :password => "foobar", :password_confirmation => "foobar" }
      end

      it "devrait créer un utilisateur" do
        expect(lambda do
          post :create, params: {:user => @attr}
        end).to change(User, :count).by(1)
      end

      it "devrait rediriger vers la page d'affichage de l'utilisateur" do
        post :create, params: {:user => @attr}
        expect(response).to redirect_to(user_path(assigns(:user)))
      end    
      
      it "devrait identifier l'utilisateur" do
        post :create, params: {:user => @attr}
        expect(controller).to be_signed_in
      end
    end
  end
  
  describe "GET 'edit'" do

    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    it "devrait réussir" do
      get :edit, params: {:id => @user}
      expect(response).to be_success
    end

    it "devrait avoir le bon titre" do
      get :edit, params: {:id => @user}
      expect(response.body).to have_title("Simple App du Tutoriel Ruby on Rails | Editer Profil")
    end

    it "devrait avoir un lien pour changer l'image Gravatar" do
      get :edit, params: {:id => @user}
      gravatar_url = "http://gravatar.com/emails"
      expect(response.body).to have_selector("a[href='#{gravatar_url}']",
                                         :text => "Changer de gravatar")
    end
  end
  
  describe "PUT 'update'" do

    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    describe "Échec" do

      before(:each) do
        @attr = { :email => "", :name => "", :password => "",
                  :password_confirmation => "" }
      end

      it "devrait retourner la page d'édition" do
        put :update, params: {:id => @user, :user => @attr}
        expect(response).to render_template('edit')
      end

      it "devrait avoir le bon titre" do
        put :update, params: {:id => @user, :user => @attr}
        expect(response.body).to have_title("Simple App du Tutoriel Ruby on Rails | Editer Profil")
      end
    end

    describe "succès" do

      before(:each) do
        @attr = { :name => "New Name", :email => "user@example.org",
                  :password => "barbaz", :password_confirmation => "barbaz" }
      end

      it "devrait modifier les caractéristiques de l'utilisateur" do
        put :update, params: {:id => @user, :user => @attr}
        @user.reload
        expect(@user. name).to  eq(@attr[:name])
        expect(@user.email).to eq(@attr[:email])
      end

      it "devrait rediriger vers la page d'affichage de l'utilisateur" do
        put :update, params: {:id => @user, :user => @attr}
        expect(response).to redirect_to(user_path(@user))
      end

      it "devrait afficher un message flash" do
        put :update, params: {:id => @user, :user => @attr}
        expect(flash[:success]).to be_present
      end
    end
  end
  
  describe "authentification des pages edit/update" do

    before(:each) do
      @user = Factory(:user)
    end

    describe "pour un utilisateur non identifié" do

      it "devrait refuser l'acccès à l'action 'edit'" do
        get :edit, params: {:id => @user}
        expect(response).to redirect_to(signin_path)
      end

      it "devrait refuser l'accès à l'action 'update'" do
        put :update, params: {:id => @user, :user => {}}
        expect(response).to redirect_to(signin_path)
      end
    end
    
    describe "pour un utilisateur identifié" do

      before(:each) do
        wrong_user = Factory(:user, :email => "user@example.net")
        test_sign_in(wrong_user)
      end

      it "devrait correspondre à l'utilisateur à éditer" do
        get :edit, params: {:id => @user}
        expect(response).to redirect_to(root_path)
      end

      it "devrait correspondre à l'utilisateur à actualiser" do
        put :update, params: {:id => @user, :user => {}}
        expect(response).to redirect_to(root_path)
      end
    end
  end
  
  
  describe "DELETE 'destroy'" do

    before(:each) do
      @user = Factory(:user)
    end

    describe "en tant qu'utilisateur non identifié" do
      it "devrait refuser l'accès" do
        delete :destroy, params: {:id => @user}
        expect(response).to redirect_to(signin_path)
      end
    end

    describe "en tant qu'utilisateur non administrateur" do
      it "devrait protéger la page" do
        test_sign_in(@user)
        delete :destroy,  params: {:id => @user}
        expect(response).to redirect_to(root_path)
      end
    end

    describe "en tant qu'administrateur" do

      before(:each) do
        admin = Factory(:user, :email => "admin@example.com", :admin => true)
        test_sign_in(admin)
      end

      it "devrait détruire l'utilisateur" do
        expect(lambda do
          delete :destroy,  params: {:id => @user}
        end).to change(User, :count).by(-1)
      end

      it "devrait rediriger vers la page des utilisateurs" do
        delete :destroy,  params: {:id => @user}
        expect(response).to redirect_to(users_path)
      end
    end
  end
  
  describe "Les pages de suivi" do

    describe "quand pas identifié" do

      it "devrait protéger les auteurs suivis" do
        get :following, params: {:id => 1}
        expect(response).to redirect_to(signin_path)
      end

      it "devrait protéger les lecteurs" do
        get :followers,  params: {:id => 1}
        expect(response).to redirect_to(signin_path)
      end
    end

    describe "quand identifié" do

      before(:each) do
        @user = test_sign_in(Factory(:user))
        @other_user = Factory(:user, :email => Factory.next(:email))
        @user.follow!(@other_user)
      end

      it "devrait afficher les auteurs suivis par l'utilisateur" do
        get :following, params: {:id => @user}
        expect(response.body).to have_selector("a[href='#{ user_path(@other_user)}']",
                                           :text => @other_user.name)
      end

      it "devrait afficher les lecteurs de l'utilisateur" do
        get :followers, params: {:id => @other_user}
        expect(response.body).to have_selector("a[href='#{ user_path(@user)}']",
                                            :text => @user.name)
      end
    end
  end
end
