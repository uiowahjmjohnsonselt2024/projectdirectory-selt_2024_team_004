Rails.application.config.session_store :cookie_store, 
  key: 'pirate_session',
  expire_after: 4.hours