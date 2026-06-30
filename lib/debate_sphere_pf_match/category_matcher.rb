# frozen_string_literal: true

module DebateSpherePfMatch
  class CategoryMatcher
    LEGACY_CATEGORY_SLUG = "match-making"

    def self.match?(category)
      return false if category.blank?

      configured_category_ids = SiteSetting.pf_match_categories_map
      return configured_category_ids.include?(category.id) if configured_category_ids.present?

      category.slug == LEGACY_CATEGORY_SLUG
    end
  end
end
