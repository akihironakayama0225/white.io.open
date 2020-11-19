class ContactController < ApplicationController
  def new
    @input_error =""
    @form_input = ValidationWithoutDb.new
  end

  def confirm
    @form_input = ValidationWithoutDb.new(params_for_validation)
    purpose_hash = {
      "1": "ご意見・ご要望",
      "2": "不具合(バグ)報告",
      "3": "Webページ制作のご依頼",
      "4": "その他"
    }
    num = params[:purpose_index].to_sym
    @form_input.purpose = purpose_hash[num]
    
    if @form_input.valid? then
      flash[:form_input] = @form_input
    else
      @input_error ="空白の項目があります"
      render :new
    end
  end

  def send_mail
    @form_input = flash[:form_input]
    if @form_input.nil?
      render plain: "二重投稿は禁止されています"
    elsif
      ContactMailer.send_mail(@form_input["name"],@form_input["mail"],@form_input["purpose"],@form_input["comment"]).deliver
    end
  end

  def params_for_validation
    params.require(:validation_without_db).permit(:name, :mail, :comment)
  end
end
