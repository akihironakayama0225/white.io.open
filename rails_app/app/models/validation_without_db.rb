class ValidationWithoutDb
    include ActiveModel::Model
    
    # カラムの役割となるもの
    attr_accessor :name, :mail, :purpose, :comment
  
      # バリデーション設定
      validates :name, presence: true
      validates :mail, presence: true
      validates :comment, presence: true

      # ToDo: @と . 制約を追加s
    
end