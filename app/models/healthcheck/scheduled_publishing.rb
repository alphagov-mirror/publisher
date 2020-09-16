require "net/http"

module Healthcheck
  class ScheduledPublishing
    def name
      :schedule_queue
    end

    def status
      queue_size_matches_edition_count? ? :ok : :warning
    end

    def details
      url = "#{Plek.new.find("publishing-api")}/healthcheck"
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      {
        publishing_api: JSON.parse(response.body),
        queue_size: queue_size,
        edition_count: edition_count,
      }
    end

    def message
      "#{edition_count} scheduled edition(s); #{queue_size} item(s) queued"
    end

  private

    def queue_size_matches_edition_count?
      queue_size == edition_count
    end

    def queue_size
      @queue_size ||= ScheduledPublisher.queue_size
    end

    def edition_count
      @edition_count ||= Edition.scheduled_for_publishing.count
    end
  end
end
