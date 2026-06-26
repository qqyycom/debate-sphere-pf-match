# frozen_string_literal: true

module DebateSpherePfMatch
  class CalendarService
    EVENT_MARKER = "discourse-post-event"

    def self.create_event(topic:, starts_at:, name:)
      return unless calendar_enabled?

      first_post = topic.ordered_posts.first
      return if first_post.nil?
      return if first_post.event.present?

      event_html = build_event_html(starts_at: starts_at, name: name)
      first_post.raw = "#{first_post.raw}\n\n#{event_html}"
      first_post.save!

      DiscoursePostEvent::Event.update_from_raw(first_post)
    end

    private

    def self.calendar_enabled?
      SiteSetting.respond_to?(:calendar_enabled) && SiteSetting.calendar_enabled
    end

    def self.build_event_html(starts_at:, name:)
      "<div class=\"#{EVENT_MARKER}\" data-start=\"#{starts_at}\" data-name=\"#{name}\" data-status=\"public\"></div>"
    end
  end
end
