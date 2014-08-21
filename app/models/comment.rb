class Comment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :message, type: :string
  
  belongs_to :media
  belongs_to :user
end
