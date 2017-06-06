class BotUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :find_bot

  def update
    @bot_user = BotUser.where(uid: params[:id], bot_instance_id: @bot.instances.select(:id)).first
    raise ActiveRecord::RecordNotFound if @bot_user.blank?
    if validate_user_attributes
      if (tz = params[:user][:timezone]).present? && !ActiveSupport::TimeZone[tz].present?
        respond_to do |format|
          format.json { render json: { error: 'Not a valid timezone provided' }, status: :bad_request }
        end
      else
        @bot_user.user_attributes[:timezone] = tz
      end

      if (ref = params[:user][:ref]).present?
        @bot_user.user_attributes[:ref] = ref
      end

      if (first_name = params[:user][:first_name]).present?
        @bot_user.user_attributes[:first_name] = first_name
      end

      if (last_name = params[:user][:last_name]).present?
        @bot_user.user_attributes[:last_name] = last_name
      end
      
      if (gender = params[:user][:gender]).present?
        @bot_user.user_attributes[:gender] = gender
      end

      if (email = params[:user][:email]).present?
        @bot_user.user_attributes[:email] = email
      end

      @bot_user.save
      head :accepted
    else
      respond_to do |format|
        format.json { render json: { error: 'Invalid Parameters' }, status: :bad_request }
      end
    end
  end

  private
  def validate_user_attributes
    params.require(:user).permit(user: [:email, :full_name, :first_name, :last_name, :gender, :timezone, :ref])
  end
end


