class BoardController < ApplicationController
  before_action :check_valid_url, only: [:edit, :fetch]

  def edit
  end

  def private
    render :edit
  end

  def fetch
    list_name = CONST::OBJ_LIST_PREFIX + params[:board_id].to_s
    logger.debug("----FETCHED----")
    objects = Redis.current.lrange(list_name, 0, -1)
    render json: {objects: objects}
  end

  def not_found
    # render "Not found page"
  end


  # --- below are accessed from User page (via ajax). ---
  def create
    # boardレコードの新規作成
    if find_board_by_user().nil?
      user = User.find_by(id: session[:user_id])
      Board.create!(my_hash: generate_hash(), user_id: user.id, draw_data: 'None')
      logger.debug("Create Board")
    else
      logger.debug("Board Already Exists")
    end
    
    logger.debug(session[:user_id])
  end

  def destroy
    # boardレコードの削除
    # ToDo: ユーザーがボードを削除した時、別のUserがAction Cableでつながっている状態だと、
    # レコードを追記されてしまう。 人数 = 0人になった時に、boardテーブルがあるか確認し、なければcacheクリアする
    board = find_board_by_user()
    if board.present?
      del_redis_records(board.id)
      board.destroy
      logger.debug("Delete Board")
    else
      logger.debug("Board Not Found")
    end
    
    logger.debug(session[:user_id])
  end

  def remake
    destroy()
    create()
    board_path = get_my_board_url()
    render json: {board_path: board_path}
  end

  def update_hash
    board = find_board_by_user()
    if board.present?
      board.my_hash = generate_hash()
      board.save!
      logger.debug("Update Hash")
    else
      logger.debug("Board Not Found")
    end
    
    board_path = get_my_board_url()
    render json: {board_path: board_path}
  end


private
  def check_valid_url
    @board_id = params.require(:board_id)
    @board_hash = params.require(:board_hash)

    begin
      if not Board.where("(id = ?) AND (my_hash = ?)", @board_id, @board_hash).present?
        redirect_to "/board/not_found"
      end
    rescue => e
      logger.debug(e)
      redirect_to "/board/not_found"
    end
  end

  def generate_hash
    # ToDo: セキュリティ, シード
    char_arr = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map { |i| i.to_a }.flatten
    return (0...16).map { char_arr[rand(char_arr.length)] }.join
  end

  def del_redis_records(id)
    Redis.current.del(CONST::OBJ_LIST_PREFIX + id.to_s)
    Redis.current.del(CONST::USER_LIST_PREFIX + id.to_s)

    logger.debug(" ---- delete redis ----")
    logger.debug(CONST::OBJ_LIST_PREFIX + id.to_s)
    logger.debug(CONST::USER_LIST_PREFIX + id.to_s)
  end
end
