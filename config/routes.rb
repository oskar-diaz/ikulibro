Ikulibro::Application.routes.draw do

  root 'welcome#index'
  put 'contacto' => 'contacts#send_contact'
  resources :reviews, only: [:index]

end
