class Media  
  include Mongoid::Document
  include Mongoid::Timestamps

  mount_uploader :file, MediaUploader
  
  field :file,         		:type => String
  
  belongs_to :user
  has_many :comments

  def media_url
  	self.file.url
  end

end
