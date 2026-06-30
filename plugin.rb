# frozen_string_literal: true

# name: debate-sphere-pf-match
# about: PF debate matchmaking system
# version: 0.2
# authors: Kyrie
# required_version: 3.3.0
require_relative "lib/debate_sphere_pf_match/category_matcher"
require_relative "lib/debate_sphere_pf_match/engine"

enabled_site_setting :pf_match_enabled

register_asset "stylesheets/common/pf-match.css"

after_initialize do
  add_to_serializer(
    :topic_view,
    :pf_match,
    include_condition: -> { DebateSpherePfMatch::CategoryMatcher.match?(object.topic.category) },
  ) do
    topic = object.topic
    match_status = DebateSpherePfMatch::MatchStatus.new(topic)

    match_status.to_h
  end

  on(:topic_created) do |topic, params, user|
    next unless DebateSpherePfMatch::CategoryMatcher.match?(topic.category)

    topic.custom_fields["pf_players"] = [].to_json
    topic.custom_fields["pf_judge"] = nil
    topic.custom_fields["pf_status"] = "recruiting"
    topic.custom_fields["pf_base_title"] = topic.title
    topic.custom_fields["pf_start_time"] = nil

    topic.save_custom_fields

    DebateSpherePfMatch::StatusTagger.sync(topic)
  end
end
