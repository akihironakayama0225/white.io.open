Rails.application.routes.draw do

  # セッション関連
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'
  resources :sessions, only: %i(new create destroy)
  post 'user/user_id', to: 'user#send_user_id'

  # 通常ページ
  root to: 'home#index'
  get 'home/index'
  get 'home/terms'
  get 'user/index'
  get 'board/:board_hash/:board_id', to: 'board#edit'
  get 'board/private'
  get 'board/not_found'

  # レコード関連
  post 'board/fetch'
  post 'board/create'
  patch 'board/update_hash'
  delete 'board/destroy'
  post 'board/remake_board', to: 'board#remake'
  post 'user/user_and_board', to: 'user#get_user_and_board_info'

  # 画像アプロード
  get 'upimage/index'
  post 'upimage/upload'

  # お問い合わせ
  get 'contact/new'
  post 'contact/confirm'
  post 'contact/send_mail'
end
