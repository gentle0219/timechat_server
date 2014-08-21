module Endpoints
  class Comments < Grape::API

    resource :comments do
      
      get :ping do
        {success:"Comments test"}
      end

      # Add comment
      # GET: /api/v1/comments/add_comment
      # parameters:
      #   token       String *required
      #   media_id    String *required
      #   message     String *required
      post :add_comment do
        media_id    = params[:media_id]
        message     = params[:message]
        user        = User.find_by_auth_token(params[:token])
        if user.present?
          media = Media.find(media_id)
          if media_id.present?
            comment = media.comments.create(message:message,user:user)
            {data:{id:comment.id, message:comment.message, user_id:user.id.to_s},message:{type:'success',value:'Added new Comment', code:TimeChatNet::Application::SUCCESS_QUERY}}
          else
            {data:[],message:{type:'error',value:'Can not find media', code:TimeChatNet::Application::ERROR_QUERY}}
          end
        else
          {data:[],message:{type:'error',value:'Can not find this user', code:TimeChatNet::Application::ERROR_CHANGE_PASSWORD}}
        end
      end

      

    end #// resouce
  end
end
