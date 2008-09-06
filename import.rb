require 'rubygems'
require 'couchrest'

cr = CouchRest.new("http://localhost:5985")
db = cr.database('reduce-example')
db.delete! rescue nil
cr.create_db('reduce-example')

time = Time.now - 3600 * 40 # start in the past

while line = gets
  time += 3600
  
  measure = Hash.new(0)
  line.chomp.split(//).each do |sensor|
    measure[sensor] += 1
  end
  
  puts "time #{time}"
  puts measure.inspect
  measure.each do |sensor, value|
    time += rand(60) # it's almost realistic :)
    reading = {
      :sensor => sensor,
      :value => value,
      :time => time.to_i
    }
    db.save(reading)
  end
end

# describe sensors a, b and c

db.save({
  :sensor => 'a',
  :description => "The first sensor, always the favorite."
})

db.save({
  :sensor => 'b',
  :description => "The second sensor, it's a little unreliable."
})

db.save({
  :sensor => 'c',
  :description => "The third sensor, just a sensor."
})