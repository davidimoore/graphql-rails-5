Rails.application.routes.draw do
  post "/graphql", to: "graphql#execute"
  #post "/auth/login", to "authentication#login"
end
