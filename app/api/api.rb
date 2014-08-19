class API < Grape::API
  prefix 'api'
  version 'v1'
  format :json

  helpers do
  
  end
  # load remaining API endpoints

  mount Endpoints::Accounts
  mount Endpoints::Friends
  mount Endpoints::Notifications
  mount Endpoints::Comments
  mount Endpoints::Medias
  # mount Endpoints::LostFounds
end
