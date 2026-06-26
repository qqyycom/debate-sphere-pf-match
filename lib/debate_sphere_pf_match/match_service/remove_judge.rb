# frozen_string_literal: true

module DebateSpherePfMatch
  class MatchService
    class RemoveJudge
      include ::Service::Base

      params do
        attribute :topic_id, :integer

        validates :topic_id, presence: true
      end

      model :topic
      policy :pf_match_topic
      policy :not_finished
      policy :not_authorized
      policy :judge_is_set

      step :remove_judge
      step :check_recruiting_status
      step :sync_title
      step :sync_status_tag

      private

      def fetch_topic(params:)
        Topic.find_by(id: params.topic_id)
      end

      def pf_match_topic(topic:)
        topic.category&.slug == "match-making"
      end

      def not_finished(topic:)
        match_status = MatchStatus.new(topic)
        !match_status.finished?
      end

      def not_authorized(guardian:, topic:)
        guardian.user.id == topic.user_id
      end

      def judge_is_set(topic:)
        match_status = MatchStatus.new(topic)
        match_status.judge_present?
      end

      def remove_judge(topic:)
        topic.custom_fields["pf_judge"] = nil
        topic.save_custom_fields
      end

      def check_recruiting_status(topic:)
        match_status = MatchStatus.new(topic)
        if match_status.ready? && !match_status.all_positions_filled?
          topic.custom_fields["pf_status"] = "recruiting"
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
