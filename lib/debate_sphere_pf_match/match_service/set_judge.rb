# frozen_string_literal: true

module DebateSpherePfMatch
  class MatchService
    class SetJudge
      include ::Service::Base

      params do
        attribute :topic_id, :integer
        attribute :user_id, :integer

        validates :topic_id, presence: true
        validates :user_id, presence: true
      end

      model :topic
      policy :pf_match_topic
      policy :not_finished
      policy :not_authorized
      policy :user_not_player
      policy :judge_not_set

      step :set_judge
      step :check_ready_status
      step :sync_title
      step :sync_status_tag

      private

      def fetch_topic(params:)
        Topic.find_by(id: params.topic_id)
      end

      def pf_match_topic(topic:)
        CategoryMatcher.match?(topic.category)
      end

      def not_finished(topic:)
        match_status = MatchStatus.new(topic)
        !match_status.finished?
      end

      def not_authorized(guardian:, topic:)
        guardian.user.id == topic.user_id
      end

      def user_not_player(topic:, params:)
        match_status = MatchStatus.new(topic)
        !match_status.players.include?(params.user_id)
      end

      def judge_not_set(topic:)
        match_status = MatchStatus.new(topic)
        !match_status.judge_present?
      end

      def set_judge(topic:, params:)
        topic.custom_fields["pf_judge"] = params.user_id
        topic.save_custom_fields
      end

      def check_ready_status(topic:)
        match_status = MatchStatus.new(topic)
        if match_status.all_positions_filled? && match_status.recruiting?
          topic.custom_fields["pf_status"] = "ready"
          topic.save_custom_fields
        end
      end

      def sync_title(topic:)
        match_status = MatchStatus.new(topic)
        topic.title = TitleFormatter.format(match_status)
        topic.save!
      end

      def sync_status_tag(topic:)
        StatusTagger.sync(topic)
      end
    end
  end
end
