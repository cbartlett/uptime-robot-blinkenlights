require 'json'
require 'open-uri'
require 'pry'
require 'sinatra'

class UptimeRobot
  def self.monitors(token)
    response = JSON.parse open("https://api.uptimerobot.com/getMonitors?apiKey=#{token}&format=json&noJsonCallback=1").read
    response['monitors']['monitor']
  end
end

class Blinkenlight

  attr_reader :hash

  def initialize(hash)
    @hash = hash
  end

  def color
    {
      '0' => '#6d6d6d',
      '1' => '#6d6d6d',
      '2' => '#5cb85c',
      '8' => '#e2ab2b',
      '9' => '#d9534f'
    }[hash['status']]
  end

  def status_name
    {
      '0' => 'paused',
      '1' => 'not checked yet',
      '2' => 'up',
      '8' => 'seems down',
      '9' => 'down'
    }[hash['status']]
  end

  def description
    "#{hash['friendlyname']}\n\nStatus is currently: \"#{status_name}\""
  end

  def to_hash
    {
      title: hash['friendlyname'],
      description: description,
      ledColor: color,
      ledLabel: hash['friendlyname']
    }
  end
end

get '/group/:token' do
  content_type :json
  monitors = UptimeRobot.monitors(params['token'])
  blinkenlights = monitors.map { |m| Blinkenlight.new(m).to_hash }
  return {
    type: 'group',
    groupTitle: 'Uptime Robot',
    groupLabel: 'Uptime Robot',
    blinkenlights: blinkenlights
  }.to_json
end
