module Hydra::SubmissionWorkflow
  ### Overriden so we don't use the MODS workflow
  def params_for_next_step_in_wokflow
    return {}
  end
end
