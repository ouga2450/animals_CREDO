Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "diagnosis_sessions#new"

  resources :diagnosis_sessions, param: :token, only: [ :new, :create, :show ] do
    member do
      patch :answer
      get   :result
    end
  end
end
