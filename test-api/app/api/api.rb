class API < Grape::API

  format :json

  get '/' do
    status 200
  end

  get '/contacts' do

    # finds two cookies from page {X-Test-Key and X-Test-Secret}
    key_id = request.headers["X-Test-Key"]
    secret = request.headers["X-Test-Secret"]

    # locate a key using the key/headers defined above
    key = Models::Key.find_by_key key_id
    if key == nil
      error!({ message: "Invalid Key" }, 400)
    end

    # if we find one compare the secret.
    bcrypt_password = BCrypt::Password.new(key.secret)
    if bcrypt_password != secret
      return nil
    end

    # use the profile to find the contacts.
    response = Models::Contact.where(user_id: key.user_id)

    return response
  end

  params do
    requires :username
    requires :password
    requires :name
  end

  post '/register' do

    # checks the database for existing username
    existing = Models::Account.where(username: params[:username])
    if existing.length != 0
      error!({ message: "That username has already been taken." }, 400)
    end

    # gives the new account a user_id using random hex. 
    # Then takes the name, number, username and password from the fields on the page and sends to the database
    user_id = SecureRandom.hex(16)
    name = params[:name]
    number = params[:number]
    username = params[:username]
    password = params[:password]

    # Returns error if username is empty
    if username == ""
      error!({ message: "Please enter a name" }, 400)
    end

    # Encrypts the password
    bcrypt_password = BCrypt::Password.create(password)

    # inserts the data into Accounts table in database
    created = Models::Account.create!(
      user_id: user_id,
      username: username,
      password: bcrypt_password,
      created: DateTime.now
    )

    # inserts the data into Profiles table in database
    Models::Profile.create!(
      user_id: user_id,
      name: name
    )
    # inserts the data into Contacts table in database
    Models::Contact.create!(
      user_id: user_id,
      name: name,
      number: number
    )
  end


  params do
    requires :username
    requires :password
  end
  post '/login' do

    # check database
    # compare password
    # if password matches create a key
    # return the key
    #

    username = params[:username]
    password = params[:password]
    
    user = Models::Account.find_by_username(username)

    bcrypt_password = BCrypt::Password.new(user.password)
    if bcrypt_password != password
      return nil
    end

    key = SecureRandom.hex(16)
    secret = SecureRandom.hex(16)
    encrypted_secret = BCrypt::Password.create(secret)

    # if password matches create a key
    created = Models::Key.create!(
      key: key,
      secret: encrypted_secret,
      user_id: user.user_id
    )

    response = {
      key: key,
      secret: secret
    }
    return response
  end

  params do
    requires :id
  end
  delete "/contact/:id" do
    
    key_id = request.headers["X-Test-Key"]
    secret = request.headers["X-Test-Secret"]

    # locate a key using the key/headers defined above
    key = Models::Key.find_by_key key_id
    if key == nil
      error!({ message: "Invalid Key" }, 400)
    end

    # if we find one compare the secret.
    bcrypt_password = BCrypt::Password.new(key.secret)
    if bcrypt_password != secret
      return nil
    end
    # now we know the user is authenticated.

    # send us the ID
    id = params[:id]
    
    # finds contact with id set in database
    contact = Models::Contact.find_by_id(id)

    # check the contact.user_id is equal to the user_id of the key
    # which is the requesting user.
    if contact.user_id != key.user_id
      error!({message:"You do not own that contact."}, 403)
    end 

    # deletes contact
    contact.destroy

    # return successful deletion
    status 204
  end

  params do
    requires :name
    requires :number
  end
  post "/contact" do 
    # what the page needs to send us
    name = params[:name]
    number = params[:number]
    
    key_id = request.headers["X-Test-Key"]
    secret = request.headers["X-Test-Secret"]

    # locate a key using the key/headers defined above
    key = Models::Key.find_by_key key_id
    if key == nil
      error!({ message: "Invalid Key" }, 400)
    end

    # if we find one compare the secret.
    bcrypt_password = BCrypt::Password.new(key.secret)
    if bcrypt_password != secret
      return nil
    end

    response = Models::Contact.find_by_user_id key.user_id
    
    # creates a new contact
    newcontact = Models::Contact.create!(
      name: name,
      number: number,
      user_id: response.user_id
    )
  end

  post "/forum" do 

  end


  route :any, '*path' do
    error!({ message: "No such route #{@env["REQUEST_METHOD"]} '#{request.path}'" }, 404)
  end

end
