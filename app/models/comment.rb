class Comment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :comment, type: :string
  belongs_to :user

end
