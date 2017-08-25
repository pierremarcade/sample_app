require 'rails_helper'

describe User do

  before(:each) do
     @attr = {
      :name => "Utilisateur exemple",
      :email => "user@example.com",
      :password => "foobar",
      :password_confirmation => "foobar"
    }
  end
  
  it "devrait créer une nouvelle instance dotée des attributs valides" do
    User.create!(@attr)
  end

  it "exige un nom" do
    bad_guy = User.new(@attr.merge(:name => ""))
    expect(bad_guy).to_not be_valid
  end
  
  it "exige une adresse email" do
    no_email_user = User.new(@attr.merge(:email => ""))
    expect(no_email_user).to_not be_valid
  end
  
  it "devrait rejeter les noms trop longs" do
    long_nom = "a" * 51
    long_nom_user = User.new(@attr.merge(:name => long_nom))
    expect(long_nom_user).to_not be_valid
  end
  
  it "devrait accepter une adresse email valide" do
    adresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    adresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      expect(valid_email_user).to be_valid
    end
  end

  it "devrait rejeter une adresse email invalide" do
    adresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    adresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      expect(invalid_email_user).to_not be_valid
    end
  end
  
  it "devrait rejeter un email double" do
    # Place un utilisateur avec un email donné dans la BD.
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    expect(user_with_duplicate_email).to_not be_valid
  end
  
  it "devrait rejeter une adresse email invalide jusqu'à la casse" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    expect(user_with_duplicate_email).to_not be_valid
  end
  
  describe "password validations" do

    it "devrait exiger un mot de passe" do
      need_password = User.new(@attr.merge(:password => "", :password_confirmation => ""))
      expect(need_password).to_not be_valid
    end

    it "devrait exiger une confirmation du mot de passe qui correspond" do
      need_confirmation_password = User.new(@attr.merge(:password_confirmation => "invalid"))
      expect(need_confirmation_password).to_not be_valid
    end

    it "devrait rejeter les mots de passe (trop) courts" do
      short = "a" * 5
      hash = @attr.merge(:password => short, :password_confirmation => short)
      expect(User.new(hash)).to_not be_valid
    end

    it "devrait rejeter les (trop) longs mots de passe" do
      long = "a" * 41
      hash = @attr.merge(:password => long, :password_confirmation => long)
      expect(User.new(hash)).to_not be_valid
    end
  end
  
  describe "password encryption" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "devrait avoir un attribut  mot de passe crypté" do
      expect(@user).to respond_to(:encrypted_password)
    end
    
    describe "authenticate method" do

      it "devrait retourner nul en cas d'inéquation entre email/mot de passe" do
        wrong_password_user = User.authenticate(@attr[:email], "wrongpass")
        expect(wrong_password_user).to be_nil
      end

      it "devrait retourner nil quand un email ne correspond à aucun utilisateur" do
        nonexistent_user = User.authenticate("bar@foo.com", @attr[:password])
        expect(nonexistent_user).to be_nil
      end

      it "devrait retourner l'utilisateur si email/mot de passe correspondent" do
        matching_user = User.authenticate(@attr[:email], @attr[:password])
        expect(matching_user).to eq(@user)
      end
    end
  end
  
  describe "Cryptage du mot de passe" do

    before(:each) do
      @user = User.create!(@attr)
    end

    
    describe "Méthode has_password?" do

      it "doit retourner true si les mots de passe coïncident" do
        expect(@user.has_password?(@attr[:password])).to be_truthy
      end    

      it "doit retourner false si les mots de passe divergent" do
        expect(@user.has_password?("invalide")).to be_falsey
      end 
    end
  end
  
  describe "Attribut admin" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "devrait confirmer l'existence de `admin`" do
      expect(@user).to respond_to(:admin)
    end

    it "ne devrait pas être un administrateur par défaut" do
      expect(@user).to_not be_admin
    end

    it "devrait pouvoir devenir un administrateur" do
      @user.toggle!(:admin)
      expect(@user).to be_admin
    end
  end
  
  
  describe "les associations au micro-message" do

    before(:each) do
      @user = User.create(@attr)
    end

    it "devrait avoir un attribut 'microposts'" do
      expect(@user).to respond_to(:microposts)
    end
  end
  
  describe "micropost associations" do

    before(:each) do
      @user = User.create(@attr)
      @mp1 = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
      @mp2 = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)
    end

    it "devrait avoir un attribut `microposts`" do
      expect(@user).to respond_to(:microposts)
    end

    it "devrait avoir les bons micro-messags dans le bon ordre" do
      expect(@user.microposts).to eq([@mp2, @mp1])
    end
    
    it "devrait détruire les micro-messages associés" do
      @user.destroy
      [@mp1, @mp2].each do |micropost|
        expect(Micropost.find_by_id(micropost.id)).to be_nil
      end
    end
  end
  
  describe "Association micro-messages" do

    before(:each) do
      @user = User.create(@attr)
      @mp1 = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
      @mp2 = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)
    end

    describe "État de l'alimentation" do

      it "devrait avoir une methode `feed`" do
        expect(@user).to respond_to(:feed)
      end

      it "devrait inclure les micro-messages de l'utilisateur" do
        expect(@user.feed.include?(@mp1)).to be_truthy
        expect(@user.feed.include?(@mp2)).to be_truthy
      end

      it "ne devrait pas inclure les micro-messages d'un autre utilisateur" do
        mp3 = Factory(:micropost,
                      :user => Factory(:user, :email => Factory.next(:email)))
        expect(@user.feed.include?(mp3)).to be_falsey
      end
    end
    
    
    describe "état de l'alimentation" do

      it "devrait avoir une alimentation" do
        expect(@user).to respond_to(:feed)
      end

      it "devrait inclure les micro-messages de l'utilisateur" do
        expect(@user.feed).to include(@mp1)
        expect(@user.feed).to include(@mp2)
      end

      it "ne devrait pas inclure les micro-messages d'un utilisateur différent" do
        mp3 = Factory(:micropost,
                      :user => Factory(:user, :email => Factory.next(:email)))
        expect(@user.feed).to_not include(mp3)
      end

      it "devrait inclure les micro-messages des utilisateurs suivis" do
        followed = Factory(:user, :email => Factory.next(:email))
        mp3 = Factory(:micropost, :user => followed)
        @user.follow!(followed)
        expect(@user.feed).to include(mp3)
      end
    end
    
  end
  
  describe "relationships" do

    before(:each) do
      @user = User.create!(@attr)
      @followed = Factory(:user)
    end

    it "devrait avoir une méthode relashionships" do
       expect(@user).to respond_to(:relationships)
    end
    
  
    it "devrait posséder une méthode `following" do
       expect(@user).to respond_to(:following)
    end
   
    it "devrait avoir une méthode following?" do
       expect(@user).to respond_to(:following?)
    end

    it "devrait avoir une méthode follow!" do
       expect(@user).to respond_to(:follow!)
    end

    it "devrait suivre un autre utilisateur" do
       @user.follow!(@followed)
       expect(@user).to be_following(@followed)
    end

    it "devrait inclure l'utilisateur suivi dans la liste following" do
      @user.follow!(@followed)
      expect(@user.following).to include(@followed)
    end
    
    it "devrait avoir une méthode unfollow!" do
      expect(@followed).to respond_to(:unfollow!)
    end

    it "devrait arrêter de suivre un utilisateur" do
      @user.follow!(@followed)
      @user.unfollow!(@followed)
      expect(@followed).to_not be_following(@followed)
    end
  end
end