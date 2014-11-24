class AvatarStatus
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :status,              type: Integer, default: 0

  belongs_to :user
  belongs_to :friend,         class_name: "User"
  
end
