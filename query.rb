# get the std deviation for each sensor

require 'rubygems'
require 'couchrest'


cr = CouchRest.new("http://localhost:5985")
db = cr.database('reduce-example')

# create and apply the views

BASEDIR = File.expand_path(File.dirname(__FILE__))

def readview view
  open(BASEDIR + "/views/#{view}").read
end

design = {
  "_id" => "_design/sensors",
  "views" => {
    "std-dev" => {
      "map" => readview("std-dev-map.js"),
      "reduce" => readview("std-dev-reduce.js"),
    },
    "by-sensor" => {
      # We reuse the map from the std-dev reduce view
      # so they'll share an index for faster generation.
      # Once the reduce=false patch is in, we can 
      # just query the std-dev view with reduce=false.
      "map" => readview("std-dev-map.js"),
    },
    "descriptions" => {
      "map" => readview("sensors-map.js")
    }
  }
}

old_design = db.get(design["_id"]) rescue nil
design["_rev"] = old_design["_rev"] if old_design

db.save(design)

puts "The most recent readings from each sensor:\n\n"

sensors = db.view("sensors/descriptions")["rows"]

now = Time.now.to_i
sensors.each do |row|
  s = row["key"]
  desc = row["value"]
  
  # note that the empty object {} sorts after all numbers (times)
  # so we use it to get the last reading per sensor
  reading = db.view("sensors/by-sensor", 
    :startkey => [s, {}], 
    :count => 1, 
    :descending => true
  )["rows"].first
      
  ago = (now - reading["key"][1]) / 60
  puts "sensor: #{s} - #{desc}"
  puts "last reading: #{reading["value"]} "
  puts "timestamp: #{reading["key"][1]} (#{ago} minutes ago)#{ago > 100 ? " ***" : ""}"
  puts
end

puts
puts "Standard Deviation:\n\n"

result = db.view("sensors/std-dev")["rows"].first["value"]
puts "Std-dev of all #{result["count"]} readings across all #{sensors.length} sensors: #{result["stdDeviation"]}"

puts
puts "Standard deviation on a per-sensor basis. This uses a single reduce query with group_level=1\n\n"


rows = db.view("sensors/std-dev", :group_level => 1)["rows"]
rows.each do |row|
  puts "sensor: #{row["key"]}"
  puts "Std-dev of all #{row["value"]["count"]} readings: #{row["value"]["stdDeviation"]}"
  puts
end
