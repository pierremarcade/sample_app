require 'rails_helper'

feature "Layouts" do
  describe "Visite" do  
    describe "quand pas identifié" do
      scenario "doit avoir un lien de connexion" do
        visit root_path
        expect(page).to have_selector("a[href='#{signin_path}']",
                                           :text => "S'identifier")
      end
      
      scenario "doit avoir un lien s'inscrire" do
        visit root_path
        expect(page).to have_selector("a[href='#{signup_path}']",
                                           :text => "S'inscrire")
      end
    end

  

    describe "quand identifié" do

      before(:each) do
        @user = Factory(:user)
        visit signin_path
        fill_in "Email",    :with => @user.email
        fill_in "Mot de passe", :with => @user.password
        click_button
      end

      scenario "devrait avoir un lien de déconnexion" do
        visit root_path
        expect(page).to have_selector("a[href='#{signout_path}']",
                                           :text => "Se déconnecter")
      end

   end

  end
end
