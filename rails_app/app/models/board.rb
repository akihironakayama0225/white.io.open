class Board < ApplicationRecord
    belongs_to :user
    # これを実現するには、 user_id カラムが必要。
end
