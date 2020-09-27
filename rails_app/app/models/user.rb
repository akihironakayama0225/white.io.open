class User < ApplicationRecord
    # https://morizyun.github.io/ruby/active-record-belongs-to-has-one-has-many.html
    # https://qiita.com/taigamikami/items/d6a2b5e4611eb4d8e13a
    has_many :boards, dependent: :destroy

    def self.from_omniauth(auth)
        # モデルを検索し、あれば先頭のレコードを返却、なければ追加
        where(provider: auth.provider, uid: auth.uid).first_or_initialize.tap do |user|
            user.provider = auth.provider
            user.uid = auth.uid
            user.name = auth.info.name
            user.email = auth.info.email
            user.image = auth.info.image
            user.oauth_token = auth.credentials.token
            user.oauth_expires_at = Time.at(auth.credentials.expires_at)
            return user
        end
    end
end
