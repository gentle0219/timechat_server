class Favorite
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :status,              type: Integer, default: 0

  belongs_to :user
  belongs_to :friend,         class_name: "User"
  
  validates_uniqueness_of :status, scope: [:user_id, :friend_id]
end
