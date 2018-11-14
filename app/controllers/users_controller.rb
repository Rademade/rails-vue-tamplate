class UsersController < ApplicationController
  before_action :authenticate_user

  def show
    render json: current_user.to_token_payload
  end
end
