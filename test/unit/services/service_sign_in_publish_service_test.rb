require 'test_helper'

class ServiceSignInPublishServiceTest < ActiveSupport::TestCase
  setup do
    Services.publishing_api.stubs(:put_content)
    Services.publishing_api.stubs(:patch_links)
    Services.publishing_api.stubs(:publish)
  end

  should "publish edition to PublishingAPI" do
    update_type = nil
    Services.publishing_api.expects(:put_content).with(content_id, payload)
    Services.publishing_api.expects(:patch_links).with(content_id, links: links)
    Services.publishing_api.expects(:publish).with(content_id, update_type, locale: locale)

    ServiceSignInPublishService.call(presenter)
  end

  def presenter
    stub(
      render_for_publishing_api: payload,
      content_id: content_id,
      links: links,
      locale: locale
    )
  end

  def content_id
    'a-content-id'
  end

  def links
    { parent: %w[6a2bf66e-2313-4204-afd5-9940de5e1d66] }
  end

  def locale
    "cy"
  end

  def payload
    @payload ||= stub
  end
end
