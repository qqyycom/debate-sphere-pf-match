# frozen_string_literal: true

module DebateSpherePfMatch
  class PfMatchController < ::ApplicationController
    requires_plugin "debate-sphere-pf-match"

    before_action :ensure_logged_in

    def add_player
      result = MatchService.call(
        action: :add_player,
        params: { topic_id: params[:topic_id], user_id: params[:user_id] },
        guardian: current_user.guardian
      )

      if result.success?
        render_match_status
      else
        render_json_error(result)
      end
    end

    def remove_player
      result = MatchService.call(
        action: :remove_player,
        params: { topic_id: params[:topic_id], user_id: params[:user_id] },
        guardian: current_user.guardian
      )

      if result.success?
        render_match_status
      else
        render_json_error(result)
      end
    end

    def set_judge
      result = MatchService.call(
        action: :set_judge,
        params: { topic_id: params[:topic_id], user_id: params[:user_id] },
        guardian: current_user.guardian
      )

      if result.success?
        render_match_status
      else
        render_json_error(result)
      end
    end

    def remove_judge
      result = MatchService.call(
        action: :remove_judge,
        params: { topic_id: params[:topic_id] },
        guardian: current_user.guardian
      )

      if result.success?
        render_match_status
      else
        render_json_error(result)
      end
    end

    def set_start_time
      result = MatchService.call(
        action: :set_start_time,
        params: { topic_id: params[:topic_id], start_time: params[:start_time] },
        guardian: current_user.guardian
      )

      if result.success?
        render_match_status
      else
        render_json_error(result)
      end
    end

    def finish
      result = MatchService.call(
        action: :finish,
        params: { topic_id: params[:topic_id] },
        guardian: current_user.guardian
      )

      if result.success?
        render_match_status
      else
        render_json_error(result)
      end
    end

    private

    def render_match_status
      match_status = MatchStatus.new(Topic.find(params[:topic_id])).to_h

      render json: success_json.merge(match_status).merge(pf_match: match_status)
    end

    def render_json_error(result)
      error_key = result.error_key || :invalid_params
      status = case error_key
      when :not_found then 404
      when :not_authorized then 403
      else 422
      end

      render json: failed_json.merge(error: error_key.to_s), status: status
    end
  end
end
