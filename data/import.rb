require 'rubygems'
require 'csv'
require 'mysql'

db = mysql.connect('localhost','root','','databasename')

CSV.foreach('filename.csv') do |row|
   ?????
   db.execute("INSERT INTO tablename ?????")
end
