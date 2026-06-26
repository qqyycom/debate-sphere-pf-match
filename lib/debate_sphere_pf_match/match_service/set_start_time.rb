# frozen_string_literal: true

module DebateSpherePfMatch
  class MatchService
    class SetStartTime
      include ::Service::Base

      params do
        attribute :topic_id, :integer
        attribute :start_time, :string

        validates :topic_id, presence: true
        validates :start_time, presence: true
      end

      model :topic
      policy :pf_match_topic
      policy :not_authorized
      policy :is_ready

      step :set_start_time
      step :update_status
      step :create_calendar_event
      step :sync_title
      step :sync_status_tag

      private

      def fetch_topic(params:)
        Topic.find_by(id: params.topic_id)
      end

      def pf_match_topic(topic:)
        topic.category&.slug == "match-making"
      end

      def not_authorized(guardian:, topic:)
        guardian.user.id == topic.user_id
      end

      def is_ready(topic:)
        match_status = MatchStatus.new(topic)
        match_status.ready?
      end

      def set_start_time(topic:, params:)
        topic.custom_fields["pf_start_time"] = params.start_time
        topic.save_custom_fields
      end

      def update_status(topic:)
        topic.custom_fields["pf_status"] = "scheduled"
        topic.save_custom_fields
      end

      def create_calendar_event(topic:, params:)
        match_status = MatchStatus.new(topic)
        CalendarService.create_event(
          topic: topic,
          starts_at: params.start_time,
          name: match_status.base_title
        )
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
