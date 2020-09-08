module GovukContentModels
  module ActionProcessors
    class NewVersionProcessor < BaseProcessor
      def process?
        true # edition.published?
      end

      def process
        convert_to = event_attributes[:convert_to]
        @edition = if !convert_to.nil?
                     edition.build_clone(convert_to.to_s.camelize.constantize)
                   else
                     edition.build_clone
                   end

        @edition.save!(validate: false) if record_action?
      end

      def record_action?
        edition.present?
      end
    end
  end
end
