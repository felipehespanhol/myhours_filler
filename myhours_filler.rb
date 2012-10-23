require 'rubygems'
require 'capybara'
require 'capybara/dsl'

#Capybara.ruby_server = false
Capybara.current_driver = :selenium
Capybara.app_host = 'http://www.myhours.com'

module MyhoursFillerModule
	class MyhoursFiller
		include Capybara::DSL

		attr_accessor :email, :password

		def get_user_data
			puts "Email: "
			@email = gets.chomp
			puts "Password: "
			system 'stty -echo'
			@password = $stdin.gets.chomp
			system 'stty echo'
		end	

		def start
			get_user_data
			puts "Opening page..."
			visit('/')
			fill_in('email', :with => @email)
			fill_in('password', :with => @password)
			click_on('Submit')
			puts "Funfa..." if find(:xpath, '//select[@name="sum1"]').visible?
		end
	end
end

t = MyhoursFillerModule::MyhoursFiller.new
t.start
