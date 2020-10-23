module GovukContentModels
  module ActionProcessors
    class RequestReviewProcessor < BaseProcessor
      def process?
        actor.govuk_editor? || actor.welsh_editor? && edition.artefact.welsh?
      end
    end
  end
end
