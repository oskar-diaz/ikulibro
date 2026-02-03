# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
if Rails.env.production?
  Rails.application.config.secret_key_base = ENV.fetch("SECRET_KEY_BASE")
else
  # Local dev/test convenience; production must set SECRET_KEY_BASE.
  Rails.application.config.secret_key_base = ENV["SECRET_KEY_BASE"] || SecureRandom.hex(64)
end
