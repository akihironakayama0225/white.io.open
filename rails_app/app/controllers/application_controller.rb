class ApplicationController < ActionController::Base
    def find_board_by_user
        Board.find_by(user_id: session[:user_id])
    end

    def get_my_board_url
        board = find_board_by_user()
        if board.nil?
            return nil
        end
        
        if Rails.env == "development" then 
            port = ":3000" 
        else 
            port = "" 
        end 
        return request.host + port + "/board/" + board.my_hash + "/" + board.id.to_s
    end
end
