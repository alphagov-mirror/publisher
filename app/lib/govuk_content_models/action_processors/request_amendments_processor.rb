module GovukContentModels
  module ActionProcessors
    class RequestAmendmentsProcessor < BaseProcessor
      def process?
        return false unless actor.govuk_editor? || actor.welsh_editor? && edition.artefact.welsh?

        if edition.in_review?
          requester_different?
        else
          true
        end
      end
    end
  end
end
