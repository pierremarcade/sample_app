require 'rails_helper'

RSpec.describe Relationship, type: :model do
  before(:each) do
    @follower = Factory(:user)
    @followed = Factory(:user, :email => Factory.next(:email))

    @relationship = @follower.relationships.build(:followed_id => @followed.id)
  end

  it "devrait créer une nouvelle instance en donnant des attributs valides" do
    @relationship.save!
  end
  
  describe "Méthodes de suivi" do

    before(:each) do
      @relationship.save
    end

    it "devrait avoir un attribut follower (lecteur)" do
      expect(@relationship).to respond_to(:follower)
    end

    it "devrait avoir le bon lecteur" do
      expect(@relationship.follower).to eq(@follower)
    end

    it "devrait avoir un attribut  followed (suivi)" do
      expect(@relationship).to respond_to(:followed)
    end

    it "devrait avoir le bon utilisateur suivi (auteur)" do
      expect(@relationship.followed).to eq(@followed)
    end
  end
  
  describe "validations" do

    it "devrait exiger un attribut follower_id" do
      @relationship.follower_id = nil
      expect(@relationship).to_not be_valid
    end

    it "devrait exiger un attribut followed_id" do
      @relationship.followed_id = nil
      expect(@relationship).to_not be_valid
    end
  end
end
