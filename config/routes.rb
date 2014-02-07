Ikulibro::Application.routes.draw do

  root 'welcome#index'
  put 'contacto' => 'contacts#send_contact'

end
