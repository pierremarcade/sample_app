require 'rails_helper'

feature "Users" do
  describe "une inscription" do
    describe "ratée" do
      scenario "ne devrait pas créer un nouvel utilisateur" do
        visit signup_path
        fill_in "Nom",          :with => ""
        fill_in "Email",        :with => ""
        fill_in "Mot de passe",     :with => ""
        fill_in "Confirmation", :with => ""
        click_button
        expect(page).to have_selector("div#error_explanation")
      end
    end
    
    describe "réussie" do
      scenario "devrait créer un nouvel utilisateur" do
        visit signup_path
        fill_in "Nom",          :with => "Example User"
        fill_in "Email",        :with =>  "user@example.com"
        fill_in "Mot de passe",     :with => "foobar"
        fill_in "Confirmation", :with => "foobar"
        click_button
        expect(page).to have_selector("div.flash.success",
                                        :text => "Bienvenue dans l'Application Exemple!")
      end
    end
  end
  
  describe "identification/déconnexion" do

    describe "l'échec" do
      scenario "ne devrait pas identifier l'utilisateur" do
        visit signin_path
        fill_in "Email",    :with => ""
        fill_in "Mot de passe", :with => ""
        click_button
        expect(page).to have_selector("div.flash.error", :text => "Combinaison Email/Mot de passe invalide.")
      end
    end

    describe "le succès" do
      scenario "devrait identifier un utilisateur puis le déconnecter" do
        user = Factory(:user)
        visit signin_path
        fill_in "Email",    :with => user.email
        fill_in "Mot de passe", :with => user.password
        click_button
        expect(page).to have_title("Simple App du Tutoriel Ruby on Rails | "+user.name)
        click_link "Se déconnecter"
        expect(page).to have_title("Simple App du Tutoriel Ruby on Rails | Accueil")
      end
    end
  end
end
