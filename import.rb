require 'rubygems'
require 'couchrest'


cr = CouchRest.new("http://localhost:5985")
db = cr.database('reduce-example')
db.delete! rescue nil
cr.create_db('reduce-example')

time = 0

while line = gets
  time += 1
  
  measure = Hash.new(0)
  line.chomp.split(//).each do |sensor|
    measure[sensor] += 1
  end
  
  puts "time #{time}"
  puts measure.inspect
  measure.each do |sensor, value|
    reading = {
      :sensor => sensor,
      :value => value,
      :time => time
    }
    db.save(reading)
  end
end