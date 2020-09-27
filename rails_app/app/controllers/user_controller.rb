class UserController < ApplicationController
  before_action :current_user, except: [:send_user_id]

  def index
    board = find_board_by_user()
    @user_id = session[:user_id]
  end

  def send_user_id
    # Utilized by login button.
    render json: {user_id: session[:user_id]}
  end

  def get_user_and_board_info
    # Utilized by user_index page.
    user_id = session[:user_id]
    board_path = get_my_board_url()

    render json: {user_id: user_id, board_path: board_path}
  end

private
  def current_user
    session[:request_url] = request.url
    if session[:user_id].nil?
      redirect_to "/auth/google_oauth2?id=sign_in"
    elsif
      logger.debug("session userID = " + session[:user_id].to_s)
      if User.find_by(id: session[:user_id]).nil?
        reset_session
        redirect_to "/auth/google_oauth2?id=sign_in"
      end
    end
  end

end
