# frozen_string_literal: true

RSpec.describe TopicViewSerializer do
  fab!(:enabled_category, :category)
  fab!(:disabled_category, :category)
  fab!(:user)

  before do
    SiteSetting.pf_match_enabled = true
    SiteSetting.pf_match_categories = enabled_category.id.to_s
  end

  def serialized_topic(topic)
    serializer = described_class.new(TopicView.new(topic), scope: Guardian.new(user), root: false)
    JSON.parse(serializer.to_json)
  end

  it "includes pf_match for topics in configured categories" do
    topic = Fabricate(:topic, category: enabled_category)

    expect(serialized_topic(topic)["pf_match"]).to include(
      "players" => [],
      "judge" => nil,
      "status" => "recruiting",
      "base_title" => topic.title,
      "start_time" => nil,
    )
  end

  it "does not include pf_match for topics outside configured categories" do
    topic = Fabricate(:topic, category: disabled_category)

    expect(serialized_topic(topic)).not_to have_key("pf_match")
  end
end
