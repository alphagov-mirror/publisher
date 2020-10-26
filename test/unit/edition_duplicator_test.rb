require "test_helper"
require "edition_duplicator"

# We might want to consider decoupling this test from
# the user and the edition, but for now at least those
# are the clear, minimal dependencies.
class EditionDuplicatorTest < ActiveSupport::TestCase
  setup do
    @laura = FactoryBot.create(:user, :govuk_editor)
    @fred  = FactoryBot.create(:user, :govuk_editor)
    @welsh_editor = FactoryBot.create(:user, :welsh_editor)
    @guide = FactoryBot.create(:guide_edition)
    @welsh_artefact = FactoryBot.create(:artefact, language: "cy")
    @welsh_guide = FactoryBot.create(:guide_edition, panopticon_id: @welsh_artefact.id)
    stub_register_published_content
  end

  def publish_item(item, actor)
    item.state = "ready"
    publish(actor, item)
  end

  test "should assign after creating new edition" do
    publish_item(@guide, @laura)

    command = EditionDuplicator.new(@guide, @laura)
    assert command.duplicate(nil, @fred)

    assert_equal @fred, command.new_edition.assigned_to
  end

  test "should be possible to create a new draft of an invalid edition" do
    guide = FactoryBot.create(:guide_edition_with_two_parts)
    publish_item(guide, @laura)

    # invalid link in body having a {:rel="external"}
    guide.parts.first.body = '[Home page](http://example.com "Home"){:rel="external"}'
    guide.parts.first.save!(validate: false)
    guide.reload

    command = EditionDuplicator.new(guide, @laura)
    assert command.duplicate(nil, @fred)
  end

  test "should not assign after creating a new edition if assignment is blank" do
    publish_item(@guide, @laura)

    command = EditionDuplicator.new(@guide, @laura)
    command.duplicate

    assert_nil command.new_edition.assigned_to
  end

  test "can provide an appropriate error message if new edition failed" do
    @laura.stubs(:new_version).with(@guide, nil).returns(false)

    command = EditionDuplicator.new(@guide, @laura)
    assert_not command.duplicate(nil, @fred)

    assert_equal "Failed to create new edition: couldn't initialise", command.error_message
  end

  test "changing the format while duplicating will make the latest edition into a new type of edition" do
    publish_item(@guide, @laura)
    artefact = @guide.artefact

    assert_equal GuideEdition, artefact.latest_edition.class

    command = EditionDuplicator.new(@guide, @laura)
    assert command.duplicate("answer_edition", @fred)

    assert_equal AnswerEdition, artefact.reload.latest_edition.class
  end

  test "changing the format while duplicating will also update the kind of the artefact" do
    publish_item(@guide, @laura)
    artefact = @guide.artefact

    assert_equal "guide", artefact.kind

    command = EditionDuplicator.new(@guide, @laura)
    assert command.duplicate("answer_edition", @fred)

    assert_equal "answer", artefact.reload.kind
  end

  test "Welsh editors may not create new versions" do
    publish_item(@guide, @laura)
    command = EditionDuplicator.new(@guide, @welsh_editor)

    assert_not command.duplicate
    assert_equal "Failed to create new edition: couldn't initialise", command.error_message
  end

  test "Welsh editors may create new versions of Welsh editions" do
    publish_item(@welsh_guide, @laura)
    command = EditionDuplicator.new(@welsh_guide, @welsh_editor)
    assert command.duplicate
  end
end
