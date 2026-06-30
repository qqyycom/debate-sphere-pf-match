# frozen_string_literal: true

RSpec.describe DebateSpherePfMatch::PfMatchController do
  fab!(:owner, :user)
  fab!(:player, :user)
  fab!(:enabled_category, :category)
  fab!(:disabled_category, :category)

  before do
    SiteSetting.pf_match_enabled = true
    SiteSetting.pf_match_categories = enabled_category.id.to_s
    sign_in(owner)
  end

  describe "#add_player" do
    it "allows topic owners to add players in configured categories" do
      topic = Fabricate(:topic, user: owner, category: enabled_category)

      post "/pf-match/add-player.json", params: { topic_id: topic.id, user_id: player.id }

      expect(response.status).to eq(200)
      expect(response.parsed_body["pf_match"]["players"]).to contain_exactly(player.id)
      expect(JSON.parse(topic.reload.custom_fields["pf_players"])).to contain_exactly(player.id)
    end

    it "rejects topics outside configured categories" do
      topic = Fabricate(:topic, user: owner, category: disabled_category)

      post "/pf-match/add-player.json", params: { topic_id: topic.id, user_id: player.id }

      expect(response.status).to eq(422)
      expect(response.parsed_body["error"]).to eq("pf_match_topic")
      expect(topic.reload.custom_fields["pf_players"]).to be_blank
    end
  end
end
