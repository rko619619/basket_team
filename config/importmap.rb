# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "bootstrap", to: "https://unpkg.com/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js", preload: true
pin "bootstrap-css", to: "https://unpkg.com/bootstrap@5.3.0/dist/css/bootstrap.min.css", preload: true
pin "@popperjs/core", to: "@popperjs--core.js" # @2.11.8
