# frozen_string_literal: true

module DebateSpherePfMatch
  class MatchStatus
    STATUSES = %w[recruiting ready scheduled finished].freeze
    MAX_PLAYERS = 4
    MAX_JUDGE = 1

    attr_reader :players, :judge, :status, :base_title, :start_time

    def initialize(topic)
      @players = JSON.parse(topic.custom_fields["pf_players"] || "[]")
      @judge = topic.custom_fields["pf_judge"]
      @status = topic.custom_fields["pf_status"] || "recruiting"
      @base_title = topic.custom_fields["pf_base_title"] || topic.title
      @start_time = topic.custom_fields["pf_start_time"]
    end

    def recruiting?
      status == "recruiting"
    end

    def ready?
      status == "ready"
    end

    def scheduled?
      status == "scheduled"
    end

    def finished?
      status == "finished"
    end

    def players_full?
      players.size >= MAX_PLAYERS
    end

    def judge_present?
      judge.present?
    end

    def all_positions_filled?
      players_full? && judge_present?
    end

    def to_h
      {
        players: players,
        judge: judge,
        status: status,
        base_title: base_title,
        start_time: start_time,
        users: selected_users,
      }
    end

    private

    def selected_users
      users_by_id = User.where(id: selected_user_ids).index_by(&:id)

      {
        players:
          players.filter_map do |user_id|
            serialize_user(users_by_id[user_id.to_i])
          end,
        judge: serialize_user(users_by_id[judge.to_i]),
      }
    end

    def selected_user_ids
      ids = players.map(&:to_i)
      ids << judge.to_i if judge.present?
      ids.uniq
    end

    def serialize_user(user)
      return nil if user.blank?

      {
        id: user.id,
        username: user.username,
        avatar_template: user.avatar_template,
      }
    end
  end
end
