# frozen_string_literal: true

RSpec.describe DebateSpherePfMatch::CategoryMatcher do
  fab!(:category)
  fab!(:other_category, :category)
  fab!(:legacy_category) { Fabricate(:category, slug: "match-making") }

  before { SiteSetting.pf_match_enabled = true }

  describe ".match?" do
    it "returns false when category is blank" do
      expect(described_class.match?(nil)).to eq(false)
    end

    it "uses the legacy match-making slug when no categories are configured" do
      SiteSetting.pf_match_categories = ""

      expect(described_class.match?(legacy_category)).to eq(true)
      expect(described_class.match?(category)).to eq(false)
    end

    it "matches categories configured in pf_match_categories" do
      SiteSetting.pf_match_categories = "#{category.id}|#{other_category.id}"

      expect(described_class.match?(category)).to eq(true)
      expect(described_class.match?(other_category)).to eq(true)
      expect(described_class.match?(legacy_category)).to eq(false)
    end
  end
end
