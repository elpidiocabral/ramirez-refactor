class UserBuilder
    def initialize()   
        @user = User.new
    end

    def personal_info(name, email, password, password_confirmation)
       @user.name = name
       @user.email = email
       @user.password = password
       @user.password_confirmation = password_confirmation
    end

    def profile_info(state, city, bio)
       @user.state = state
       @user.city = city
       @user.bio = bio
    end

    def optional_info(specialization, services_price, photographer)
       @user.specialization = specialization
       @user.services_price = services_price
       @user.photographer = photographer
    end

    def build()
        user = @user
        @user = User.new
        # return
        user 
    end
end