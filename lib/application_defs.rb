require_relative '../config/environment.rb'
require_relative '../bots/bots.rb'
require 'json'

# Assortment of constant definitions.
module ApplicationDefs
  # @todo Not sure if this is necessary
  def self.included(klass)
    klass.class_eval do
      include Bots
    end
  end

  JSON.parse(File.read(Rails.root.join('config', 'constants.json'))).each do |constant, val|
    ApplicationDefs.const_set(constant, val) unless const_defined? constant
  end

  LOG_DIRECTORY = Rails.root.join('log') unless const_defined? :LOG_DIRECTORY

  MATCH_LOG_DIRECTORY = File.join(LOG_DIRECTORY, 'match_logs') unless const_defined? :MATCH_LOG_DIRECTORY

  # Human opponent names map to nil
  def self.game_definitions
    lcl_game_defs = Bots::STATIC_GAME_DEFINITIONS.dup
    # Uncomment these lines to include user names in the opponent selection menu.
    #lcl_game_defs.each do |type, prop|
    #User.each do |user|
    #    prop[:opponents].merge! user.name => nil
    #  end
    #end
  end

  # @return [Array<Class>] Returns only the names that correspond to bot runner
  #   classes as those classes.
  def self.bots(game_def_key, player_names)
    player_names.map do |name|
      game_definitions[game_def_key][:opponents][name]
    end.reject { |elem| elem.nil? }
  end
  def self.random_seat(num_players)
    rand(num_players) + 1
  end
  def self.random_seed
    random_float = rand
    random_int = (random_float * 10**random_float.to_s.length).to_i
  end
end

