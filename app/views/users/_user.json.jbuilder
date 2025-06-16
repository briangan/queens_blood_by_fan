json.extract! user, :id, :email, :username, :rank, :rating, :created_at, :updated_at
json.url user_url(user, format: :json)
