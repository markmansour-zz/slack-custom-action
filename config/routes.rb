Rails.application.routes.draw do
  get '/', to: 'job_workers#index'
  post '/', to: 'job_workers#create'
end
