require 'rails_helper'

feature "Microposts" do
  before(:each) do
    user = Factory(:user)
    visit signin_path
    fill_in "Email",    :with => user.email
    fill_in "Mot de passe", :with => user.password
    click_button
  end

  describe "création" do

    describe "échec" do

      scenario "ne devrait pas créer un nouveau micro-message" do
        expect(lambda do
          visit root_path
          fill_in :micropost_content, :with => ""
          click_button
          expect(page).to have_selector("div#error_explanation")
        end).to_not change(Micropost, :count)
      end
    end

    describe "succès" do

      scenario "devrait créer un nouveau micro-message" do
        content = "Lorem ipsum dolor sit amet"
        expect(lambda do
          visit root_path
          fill_in :micropost_content, :with => content
          click_button
          expect(page).to have_selector("span.content", :text => content)
        end).to change(Micropost, :count).by(1)
      end
    end
  end
end
