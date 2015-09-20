require 'nokogiri'
require 'open-uri'
require 'json'
require 'pry'

json = File.read('config.json')
secret_config = JSON.parse(json)['big_image']

imgur_gallery = secret_config['imgur_gallery']

gallery_images = Array.new

SCHEDULER.every '1m', :first_in => 0 do
  if gallery_images.empty?
    gallery = Nokogiri::HTML(open(imgur_gallery))
    gallery_images = gallery.css("div.post-image")
  end

  image_url = nil

  while image_url.nil?
    if gallery_images.empty?
      image_url = "i.imgur.com/0mAflZ7.jpg"
    else
      image = gallery_images.shift
    end

    if !image.css("img").empty?
      image_url = image.css("img")[0].attributes["src"].value
    elsif !image.css("source").empty?
      image_url = image.css("source")[1].attributes["src"].value
    end
  end

  send_event('picture', { image: "http:#{image_url}"})
end