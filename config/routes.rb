Rails.application.routes.draw do
  root "quizzes#index"

  resources :quizzes,
    only: %i[index show],
    param: :slug
end
