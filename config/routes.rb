Rails.application.routes.draw do

  get 'upload/index'

  get 'upload/upload_file'

  get 'idioms/update_score'

  get 'idioms/edit'

  get 'idioms/update'

#  get 'cards/new'
#  get 'cards/create'
#  get 'cards/destroy'
#  get 'cards/edit'

  match '/contact', to: 'static_pages#contact', via: 'get'
  # generates contact_url and contact_path
  match '/login', to: 'sessions#new', via: 'get'
  match '/logout',to:'sessions#destroy', via: 'delete'
  match '/work_as_guest', to:'sessions#become_guest', via: 'delete'
  #match '/password_reminder', to: 'sessions#password_reminder', via: 'post'
  match '/renshuu/:id/:kind', to:'dicts#start_training', via: 'get', as: :renshuu
  match '/update_score/:id', to:'idioms#update_score', via: 'patch', as: :update_score

  match '/tester', to: 'static_pages#tester', via: 'get'

  resources :dicts do
    get :select_for_import  # Nested. ID will be passed as :dict_id
    get :import_show_result
    resources :cards
    resources :upload, only: [:index] do
      member do
        post :upload_file
        post :import_dict
        get  :confirm_import
      end
    end

  end

  resources :idioms
  resources :users
  resources :sessions

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  root 'home#init'
  # generates root_url and root_path

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
