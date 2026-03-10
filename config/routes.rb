Rails.application.routes.draw do

  root 'welcome#index'
  get 'featured_review' => 'welcome#featured_review'
  put 'contacto' => 'contacts#send_contact'
  resources :reviews, only: [:index]
  get 'sitemap.xml' => 'sitemaps#index', defaults: { format: 'xml' }
  get 'robots.txt' => 'robots#index', defaults: { format: 'text' }

end
