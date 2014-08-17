module Endpoints
  class WorkOrders < Grape::API

    resource :work_orders do
      
      get :ping do
        { :success => 'work order test' }
      end

      desc "Create new work order"
      post do
        user = User.find_by_token(params[:auth_token])
        if user.present?
          work_order = user.work_orders.build(location:params[:location], category:params[:category], title:params[:title], details:params[:details], level:params[:level].downcase, property_id:params[:property_id])
          if work_order.save
            {success: {id:work_order.id.to_s, title:work_order.title}}
          else
            {failed: work_order.errors.messages.to_json}
          end        
        else
          {failed: 'Cannot find this token, please login again'}
        end
      end

      desc "Get category list"
      get :categories do
        categories = Category.all_categories.map{|cat| {name:cat.full_name.join('>'), id:cat.id.to_s}}
        {success:categories}
      end

    end

  end
end
