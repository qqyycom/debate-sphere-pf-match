# frozen_string_literal: true

module DebateSpherePfMatch
  class MatchService
    def self.call(action:, params:, guardian:)
      service_class = case action
      when :add_player then AddPlayer
      when :remove_player then RemovePlayer
      when :set_judge then SetJudge
      when :remove_judge then RemoveJudge
      when :set_start_time then SetStartTime
      when :finish then Finish
      else raise ArgumentError, "Unknown action: #{action}"
      end

      service_class.call(params: params, guardian: guardian)
    end
  end
end
