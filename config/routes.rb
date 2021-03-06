ArpSpreadsheetGenerator::Application.routes.draw do

  root 'spreadsheets#index'

  put :process_mass_line, controller: :mass_lines, action: :process_spreadsheet

  resources :mass_lines, :customizable_lines


  resources :arps do
    member do
      get 'generate'
      get 'customize'
    end
  end

  resources :spreadsheets do
    member do
      get 'generate_arps'
      get 'download'
      get 'images_to_rename'
      get 'missing_arps'
    end
  end

end
