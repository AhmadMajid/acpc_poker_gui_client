module MatchStartHelper
  def hidden_match_id() 'hidden_id' end
  def hidden_match_name() 'hidden_name' end
  def hidden_game_def_file_name() 'hidden_game_def_file_name' end
  def hidden_num_hands() 'hidden_num_hands' end
  def hidden_seat() 'hidden_seat' end
  def hidden_rand_seed() 'hidden_rand_seed' end
  def hidden_submit() 'hidden_submit' end
  def hidden_start_opponents() 'hidden_start_opponents' end
  def hidden_begin_match() 'hidden-begin_match' end
  def hidden_poll() 'hidden-poll' end

  # Renders a +JavaScript+ template that sends parameters to
  # +PlayerActionsController+ so that it can connect to an
  # ACPC dealer instance.
  def send_parameters_to_connect_to_dealer
    render 'match_start/send_parameters_to_connect_to_dealer'
  end

  # Hidden form, within which game parameters may be placed that can be
  # submitted to the +PlayerActionsController+.
  def hidden_begin_match_form(match_id)
    form_tag match_home_url, :remote => true do
      form = hidden_field_tag(:match_id, match_id, :id => hidden_match_id)

      form << submit_tag('', :id => hidden_begin_match, style: 'visibility: hidden')
    end
  end

  def hidden_match_start_poll_form(match_id)
    form_tag match_start_poll_url, :remote => true do
      form = hidden_field_tag(:match_id, match_id, :id => hidden_match_id)

      form << submit_tag('', :id => hidden_poll, style: 'visibility: hidden')
    end
  end

  def label_for_required(label)
    "<abbr title='required'>*</abbr> #{label}".html_safe
  end

  def num_players(game_def_key)
    ApplicationDefs::GAME_DEFINITIONS[game_def_key][:num_players]
  end

  def truncate_opponent_names_if_necessary(match_params)
    while (
      match_params[:opponent_names].length >
      num_players(match_params[:game_definition_key].to_sym) - 1
    )
      match_params[:opponent_names].pop
    end
    match_params[:opponent_names]
  end
  def wait_for_match_to_start
    respond_to do |format|
      format.js do
        replace_page_contents wait_for_match_to_start_partial
      end
    end
  end

  def matches_to_join
    @matches_to_join ||= Match.all.select do |m|
      m.opponent_names &&
      m.opponent_names.any? do |name|
        # @todo Should be: name.match(user_name)
        name.match(ApplicationDefs::HUMAN_OPPONENT_NAME)
      end &&
      m.slices.empty? &&
      !m.name_from_user.match(/^_+$/)
    end
  end
  def seats_to_join
    matches_to_join.inject({}) do |hash, lcl_match|
      # Remove seats already taken by players who have already joined this match
      hash[lcl_match.name_from_user] = (
        # @todo This is what it should be: lcl_match.human_opponent_seats(user_name) -
        lcl_match.human_opponent_seats -
        Match.where(name: lcl_match.name).map { |m| m.seat }
      )
      hash
    end
  end

  def matches_to_rejoin
    @matches_to_rejoin ||= Match.all.select do |m|
      m.user_name == user_name &&
      !m.name_from_user.match(/^_+$/) &&
      !m.finished? &&
      !m.slices.empty?
    end
  end
  def seats_to_rejoin
    matches_to_rejoin.inject({}) do |hash, lcl_match|
      hash[lcl_match.name_from_user] = lcl_match.human_opponent_seats
      hash[lcl_match.name_from_user] << lcl_match.seat
      hash[lcl_match.name_from_user]
      hash
    end
  end
end