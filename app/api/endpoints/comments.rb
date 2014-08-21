module Endpoints
  class Comments < Grape::API

    resource :comments do
      
      get :ping do
        {success:"Comments test"}
      end

      # Get comments by media id
      # GET: /api/v1/comments
      # parameters:
      #   token       String *required
      #   media_id    String *required
      
      get do
        media_id    = params[:media_id]
        user        = User.find_by_auth_token(params[:token])
        if user.present?
          media = Medium.find(media_id)
          if media.present?
            comments = media.comments.map{|cm| cm.api_detail}
            {data:comments,message:{type:'success',value:'get comments', code:TimeChatNet::Application::SUCCESS_QUERY}}
          else
            {data:[],message:{type:'error',value:'Can not find media', code:TimeChatNet::Application::MEDIA_NOT_FOUND}}
          end
        else
          {data:[],message:{type:'error',value:'Can not find this user', code:TimeChatNet::Application::ERROR_LOGIN}}
        end
      end


      # Add comment
      # POST: /api/v1/comments/add_comment
      # parameters:
      #   token       String *required
      #   media_id    String *required
      #   comment     String *required
      post :add_comment do
        media_id    = params[:media_id]
        comment     = params[:comment]
        user        = User.find_by_auth_token(params[:token])
        if user.present?
          media = Medium.find(media_id)
          if media.present?
            comment = media.comments.create(comment:comment,user:user)
            media.user.send_notification_add_new_comment(user)
            {data:{id:comment.id, comment:comment.comment, user_id:user.id.to_s},message:{type:'success',value:'Added new Comment', code:TimeChatNet::Application::SUCCESS_QUERY}}
          else
            {data:[],message:{type:'error',value:'Can not find media', code:TimeChatNet::Application::MEDIA_NOT_FOUND}}
          end
        else
          {data:[],message:{type:'error',value:'Can not find this user', code:TimeChatNet::Application::ERROR_LOGIN}}
        end
      end

      

    end #// resouce
  end
end
