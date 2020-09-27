class UpimageController < ApplicationController
  def index
  end

  def upload
    img = params.require(:upimg)
    logger.debug(img)
    name = img.original_filename
    whitelist = [".jpg", ".jpeg", ".png", ".gif", ".svg"]

    if !whitelist.include?(File.extname(name).downcase)
      render status: :method_not_allowed, json: {comment: "この形式には対応していません", url: ""}
      return
    end
    if img.size > 5.megabyte
      render status: :method_not_allowed, json: {comment: "ファイルサイズは5MB以下です", url: ""}
      return
    end

    File.open("public/onboard_images/#{name}", "wb"){
      |f| f.write(img.read)
    }
    if  Rails.env === "development" then
      url = "//#{request.host}:3000/onboard_images/#{name}"
    else
      url = "//#{request.host}/onboard_images/#{name}"
    end
    
    render status: :ok, json: {comment: "", url: url}
  end
end
