module GovukContentModels
  module ActionProcessors
    class ApproveReviewProcessor < BaseProcessor
      def process?
        (actor.govuk_editor? || actor.welsh_editor? && edition.artefact.welsh?) && requester_different?
      end
    end
  end
end
