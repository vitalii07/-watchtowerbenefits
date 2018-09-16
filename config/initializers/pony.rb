if Rails.env.development?
  Pony.options = {
    via: LetterOpener::DeliveryMethod,
    via_options: {location: "#{Rails.root}/tmp/letter_opener"}
  }
elsif Rails.env.test?
  {via: :test}
else
  Pony.options = {
    via: :smtp,
    via_options: {
      address: 'smtp.sendgrid.net',
      port: '587',
      domain: 'heroku.com',
      user_name: ENV['SENDGRID_USERNAME'],
      password: ENV['SENDGRID_PASSWORD'],
      authentication: :plain,
      enable_starttls_auto: true
    }
  }
end
