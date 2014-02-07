class ContactMailer < ActionMailer::Base
  default from: "oskar@ikusuki.com"

  def contact_email (nombre, email, address, comments)
    @nombre = nombre
    @email = email
    @address = address
    @comments = comments
    mail(to: 'koki142@gmail.com', subject: "Un ikulibro, señora!")
  end
end
