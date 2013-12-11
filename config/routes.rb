Spree::Core::Engine.routes.draw do
  get '/admin/reports/current_stock', to: 'admin/reports#current_stock', as: 'current_stock_admin_reports'
end
