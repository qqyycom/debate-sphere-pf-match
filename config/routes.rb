# frozen_string_literal: true

DebateSpherePfMatch::Engine.routes.draw do
  post "/pf-match/add-player" => "pf_match#add_player"
  post "/pf-match/remove-player" => "pf_match#remove_player"
  post "/pf-match/set-judge" => "pf_match#set_judge"
  post "/pf-match/remove-judge" => "pf_match#remove_judge"
  post "/pf-match/set-start-time" => "pf_match#set_start_time"
  post "/pf-match/finish" => "pf_match#finish"
end

Discourse::Application.routes.draw do
  mount DebateSpherePfMatch::Engine, at: "/"
end
