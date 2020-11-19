class ContactMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.contact_mailer.send_mail.subject
  #
  def send_mail(name,mail,purpose,comment)
    @usr = {name: name, mail: mail, purpose: purpose, comment: comment}
    mail to:  @usr[:mail],
    subject: 'お問い合わせを受け付けました'
  end
end
