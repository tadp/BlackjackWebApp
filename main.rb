require 'sinatra'
require 'sinatra/reloader'

set :sessions, true

helpers do
  def calculate_total(cards)
    arr= cards.map{|element| element[1]}

    total = 0
    arr.each do |a|
      if a == "A"
        total +=11
      else
        total += a.to_i == 0 ? 10 : a.to_i
      end
    end

    #correct for Aces
    arr.select{|element| element == "A"}.count.times do
      break if total <=21
      total -= 10
    end

    total
  end
  #calculate_total(session[:dealers_cards]) => 20

#   Original attempt
#   def card_image1(cards)
#     arr = cards.map{|element| element[0]}
#     arr.each do |a|
#     ret_value_suit=  case a
#                   when 'h' then 'hearts_'
#                   when 's' then 'spades_'
#                   when 'd' then 'diamonds_'
#                   when 'c' then 'clubs_'
#                 end
#     ret_value_suit
#     end

#     arr2 = cards.map{|element| element[1]}

#     arr2.each do |a|
#         if a.to_i == 0 
#             ret_value_face=  case a
#                           when 'J' then 'jack'
#                           when 'Q' then 'queen'
#                           when 'K' then 'king'
#                           when 'A' then 'ace'
#                         end
#             ret_value_face
#         else
#         ret_value_face = a.to_i
#         end
#       end

#       "<img src='/images/cards/#{ret_value_suit}_#{ret_value_face}.jpg'>"
#   end
# end

  def card_image(card) #['H','4']
    suit = case card[0]
      when 'H' then 'hearts'
      when 'D' then 'diamonds'
      when 'C' then 'clubs'
      when 'S' then 'spades'
    end

    value = card[1]
    if ['J', 'Q', 'K','A'].include?(value)
      value = case card[1]
        when 'J' then 'jack'
        when 'Q' then 'queen'
        when 'K' then 'king'
        when 'A' then 'ace'
      end
    end

    "<img class='card_image' src='/images/cards/#{suit}_#{value}.jpg'>"
  end
end



before do
  @show_hit_or_stay_buttons = true
end


get '/' do
  if session[:player_name]
    redirect '/game'
  else
    redirect '/new_player'
  end
end

get '/new_player' do
  erb :new_player
end

post '/new_player' do

  if params[:player_name].empty?
    @error = "Name is required"
    halt erb(:new_player)
  end
  # "This is a post of '#{params[:player_name]}'"
  session[:player_name]=params[:player_name]
  redirect '/game'
end

get '/game' do
  #create a deck and put it in session
  suits = ['H', 'D','C','S']
  values = '2','3','4','5','6','7','8','9','10','J','Q','K','A'
  session[:deck]=suits.product(values).shuffle! #[ ['H','9'], ['C','K']...]
  #deal cards
  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
    #dealer cards
    #player cards
  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop

  player_total = calculate_total(session[:player_cards])
  if player_total == 21
    @success = "#{session[:player_name]} hit Blackjack!"
    @show_hit_or_stay_buttons = false
  elsif calculate_total(session[:player_cards]) > 21
    @error = "Sorry, it looks like #{session[:player_name]} busted."
    @show_hit_or_stay_buttons = false
  end
  erb :game
end


post '/game/player/stay' do
  @success = "#{session[:player_name]} has chosen to stay"
  @show_hit_or_stay_buttons = false
  redirect '/game/dealer'
end

get '/game/dealer' do
  @show_hit_or_stay_buttons = false
 
  #decision tree
  dealer_total = calculate_total(session[:dealer_cards])

  if dealer_total == 21
    @error = "Sorry, dealer hit blackjack"
  elsif dealer_total > 21
    @success = "Congratulations, dealer busts. You win."
  elsif dealer_total >= 17 #17,18,19,20
    #dealer stays
    redirect '/game/compare'
  else
    #dealer hits
    @show_dealer_hit_button = true

  end
  erb :game
end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect '/game/dealer'
end

get '/game/compare' do
  @show_hit_or_stay_buttons = false
  player_total = calculate_total(session[:player_cards])
  dealer_total = calculate_total(session[:dealer_cards])

  if player_total < dealer_total
    @error = "Sorry, you lost"
  elsif player_total > dealer_total
    @success = "Congrats, you won!"
  else
    @success = "It's a tie"
  end

  erb :game
end