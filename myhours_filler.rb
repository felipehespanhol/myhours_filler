# encoding: utf-8

require 'rubygems'
require 'capybara'
require 'capybara/dsl'
require 'yaml'

#Capybara.ruby_server = false
Capybara.current_driver = :selenium
Capybara.app_host = 'http://www.myhours.com'

module MyhoursFillerModule
	class MyhoursFiller
		include Capybara::DSL

		attr_accessor :options, :email, :password, :today, :begining_before_lunch, :begining_after_lunch, :ending_before_lunch, :ending_after_lunch

		def initialize()
			@options = YAML.load_file('data.yaml')
			if @options['email']
				@email = @options['email']
			else
				puts "Email: "
				@email = gets.chomp
			end
			if @options['password']
				@password = @options['password']
			else
				puts "Password: "
				system 'stty -echo'
				@password = $stdin.gets.chomp
				system 'stty echo'
			end
			@begining_before_lunch =  @options['begining_before_lunch']
			@ending_before_lunch =  @options['ending_before_lunch']
			@begining_after_lunch =  @options['begining_after_lunch']
			@ending_after_lunch =  @options['ending_after_lunch']
		end	

		def day_filling
			# Register time schedule before lunch
			fill_in('Text1', :with => @begining_before_lunch)
			fill_in('Text2', :with => @ending_before_lunch)
			click_button('Submit')
			# Register time schedule after lunch
			fill_in('Text1', :with => @begining_after_lunch)
			fill_in('Text2', :with => @ending_after_lunch)
			click_button('Submit')
		end

		def month_filling
			today = find('.bgLiteBorder').find('a').text.gsub(/\s+/, "").to_i
			today.downto(1) do |day|
				puts "Achou o dia #{ day.to_s } :)"
				# Compare if its the first td in the table, or, in other words, check if its sunday
				day_tr = find('a', :text => " #{day.to_s} ").find(:xpath, './/..').find(:xpath, './/..')
				day_tr_first_child_text =  day_tr.find('td:first-child').find('a').text
				# Compare if its the last td in the table, or, in other words, check if its saturday
				day_tr_last_child_text =  day_tr.find('td:last-child').find('a').text
				if day_tr_first_child_text != " #{day.to_s} " && day_tr_last_child_text != " #{day.to_s} "
					puts "#{day.to_s} não é fim de semana"
				else
					puts "#{day.to_s} é fim de semana"
				end
				click_link("#{day.to_s}") 
			end
		end

		def start
			puts "Starting to act..."
			# Visit initial page and login
			visit('/')
			fill_in('email', :with => @email)
			fill_in('password', :with => @password)
			click_on('Submit')
			puts "Logged in..." if find(:xpath, '//select[@name="sum1"]').visible?
			if @options['month_filling'] == true
				month_filling
			else
				day_filling
			end
			puts "Filled..." if find(:xpath, '//select[@name="sum1"]').visible?
		end
	end
end

t = MyhoursFillerModule::MyhoursFiller.new
t.start
