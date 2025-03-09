namespace :dev do
  desc "Reset the database and start the server"
  task reset_server: :environment do
    puts "Remove old tmp files to ensure no caching messes up the reset..."
    FileUtils.rm_rf(Dir["tmp/*"])
    puts "Resetting database..."
    system("bundle exec rails db:drop:_unsafe db:create db:migrate db:seed RAILS_ENV=development")
    puts "Starting Rails server..."
    exec "rails server"
  end
end
