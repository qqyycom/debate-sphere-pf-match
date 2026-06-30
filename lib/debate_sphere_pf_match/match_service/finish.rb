# frozen_string_literal: true

module DebateSpherePfMatch
  class MatchService
    class Finish
      include ::Service::Base

      params do
        attribute :topic_id, :integer

        validates :topic_id, presence: true
      end

      model :topic
      policy :pf_match_topic
      policy :not_authorized
      policy :is_scheduled

      step :finish
      step :sync_title
      step :sync_status_tag

      private

      def fetch_topic(params:)
        Topic.find_by(id: params.topic_id)
      end

      def pf_match_topic(topic:)
        CategoryMatcher.match?(topic.category)
      end

      def not_authorized(guardian:, topic:)
        guardian.user.id == topic.user_id
      end

      def is_scheduled(topic:)
        match_status = MatchStatus.new(topic)
        match_status.scheduled?
      end

      def finish(topic:)
        topic.custom_fields["pf_status"] = "finished"
        topic.save_custom_fields
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
