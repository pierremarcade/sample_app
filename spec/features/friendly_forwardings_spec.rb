require 'rails_helper'

feature "FriendlyForwardings" do
  scenario "devrait rediriger vers la page voulue après identification" do
    user = Factory(:user)
    visit edit_user_path(user)
    # Le test suit automatiquement la redirection vers la page d'identification.
    fill_in "Email",    :with => user.email
    fill_in "Mot de passe", :with => user.password
    click_button
    # Le test suit à nouveau la redirection, cette fois vers users/edit.
    expect(page).to have_title("Simple App du Tutoriel Ruby on Rails | Editer Profil")
  end
end