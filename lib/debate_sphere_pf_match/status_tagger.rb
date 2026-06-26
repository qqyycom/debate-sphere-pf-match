# frozen_string_literal: true

module DebateSpherePfMatch
  class StatusTagger
    TAGS_BY_STATUS = {
      "recruiting" => "pf-recruiting",
      "ready" => "pf-ready",
      "scheduled" => "pf-scheduled",
      "finished" => "pf-finished",
    }.freeze

    STATUS_TAGS = TAGS_BY_STATUS.values.freeze

    def self.sync(topic)
      return if !SiteSetting.tagging_enabled

      status_tag = TAGS_BY_STATUS[MatchStatus.new(topic).status]
      return if status_tag.blank?

      old_tag_names = topic.tags.pluck(:name)
      new_tag_names = (old_tag_names - STATUS_TAGS) + [status_tag]
      return if old_tag_names.sort == new_tag_names.sort

      DiscourseTagging.tag_topic_by_names(
        topic,
        Discourse.system_user.guardian,
        new_tag_names,
      )
    end
  end
end
