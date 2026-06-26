# frozen_string_literal: true

module DebateSpherePfMatch
  class TitleFormatter
    STATUS_LABELS = {
      "recruiting" => nil,
      "ready" => "待开始",
      "scheduled" => "已排期",
      "finished" => "已结束",
    }.freeze

    def self.format(match_status)
      parts = []
      status_label = STATUS_LABELS[match_status.status]
      parts << "【#{status_label}】" if status_label
      parts << "【选手: #{match_status.players.size}/4】"
      parts << "【裁判: #{match_status.judge_present? ? 1 : 0}/1】"
      parts << match_status.base_title
      parts.join
    end
  end
end
