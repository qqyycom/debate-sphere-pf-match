# frozen_string_literal: true

module DebateSpherePfMatch
  class Engine < ::Rails::Engine
    engine_name "debate_sphere_pf_match"
    isolate_namespace DebateSpherePfMatch

    config.autoload_paths << File.join(config.root, "lib")
  end
end
