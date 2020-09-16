require "gds_api/publishing_api"

module Services
  def self.publishing_api
    client = Aws::ServiceDiscovery::Client.new(
      region: "eu-west-1",
    )

    resp = client.discover_instances({
      health_status: "ALL",
      max_results: 10,
      namespace_name: "govuk-publishing-platform",
      service_name: "publishing-api",
    })

    instance = resp.instances.sample.attributes

    GdsApi::PublishingApi.new(
      "http://#{instance.dig("AWS_INSTANCE_IPV4")}:#{instance.dig("AWS_INSTANCE_PORT")}",
      bearer_token: ENV["PUBLISHING_API_BEARER_TOKEN"] || "example",
    )
  end
end
