class Micropost < ApplicationRecord
  belongs_to :user
  default_scope { order('microposts.created_at DESC')}
  
  validates :content, :presence => true, :length => { :maximum => 140 }
  validates :user_id, :presence => true

  # Renvoie les micro-messages des utilisateurs suivis par un utilisateur donné.
  scope :from_users_followed_by, lambda { |user| followed_by(user) }

  private

    # Renvoie une condition SQL pour les utilisateurs suivis par l'utilisateur donné.
    # Nous incluons aussi ses propres micro-messages.
    def self.followed_by(user)
      followed_ids = %(SELECT followed_id FROM relationships
                       WHERE follower_id = :user_id)
      where("user_id IN (#{followed_ids}) OR user_id = :user_id",
            { :user_id => user })
    end
end
