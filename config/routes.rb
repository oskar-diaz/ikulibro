Rails.application.routes.draw do

  root 'welcome#index'
  put 'contacto' => 'contacts#send_contact'
  resources :reviews, only: [:index]
  get 'sitemap.xml' => 'sitemaps#index', defaults: { format: 'xml' }
  get 'robots.txt' => 'robots#index', defaults: { format: 'text' }

end
