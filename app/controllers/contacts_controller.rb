class ContactsController < ApplicationController

  def send_contact
    @nombre = params[:name]
    @email = params[:email]
    @address = params[:address]
    @comments = params[:comments]
    ContactMailer.contact_email(@nombre, @email, @address, @comments).deliver
    msg = "<h3>¡Muchas gracias!! ¡¡Email recibido!!</h3> <br/>¡¡Lo leo y me pongo en contacto contigo ya mismo, ya verás!"
    render :json => msg, :status => 200 and return
  end
end
