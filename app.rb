require 'net/http'
require 'json'
require 'pry'
require 'redis'

def get_artist_id(name)
  url = "https://api.spotify.com/v1/search?q=#{name}&type=artist"

  redis = Redis.new

  if redis.exists url
    response = redis.get url
    p "cache hit"
  else
    response = Net::HTTP.get(URI(url))
    redis.set url, response
    p "cache miss"
  end

  data = JSON.parse(response)
  artist_id = data["artists"]["items"][0]["id"]
  puts "The #{name} artist id is #{artist_id}"
  puts ''
  artist_id
end

def get_top_tracks(artist_id)
  url = "https://api.spotify.com/v1/artists/#{artist_id}/top-tracks?country=US"

  redis = Redis.new

  if redis.exists url
    response = redis.get url
    p "cache hit"
  else
    response = Net::HTTP.get(URI(url))
    redis.set url, response
    p "cache miss"
  end

  top_track_data = JSON.parse(response)
  tracks = top_track_data['tracks']

  tracks.each_with_index do |track, index|
    name = track['name']
    puts "Track #{index + 1}: #{name}"
  end
end



def main

puts 'Enter the name of an artist to look up:'
artist_name = gets.chomp
artist_id = get_artist_id(artist_name)

get_top_tracks(artist_id)

end

main if __FILE__ == $PROGRAM_NAME
