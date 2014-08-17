class Owner
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,					    :type => String
  field :pt_id,             :type => String  
  field :address1,                :type => String
  field :address2,                :type => String
  field :city,                    :type => String
  field :state,                   :type => String
  field :zip_code,                :type => String
  field :phone,                   :type => String
  field :phone2,                   :type => String
  
  has_one :property
  
end
