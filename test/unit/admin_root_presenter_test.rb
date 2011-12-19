require 'test_helper'

class AdminRootPresenterTest < ActiveSupport::TestCase

  setup do
    json = JSON.dump("name" => "Childcare", "slug" => "childcare")
    stub_request(:get, %r{http://panopticon\.test\.gov\.uk/artefacts/.*\.js}).
      to_return(:status => 200, :body => json, :headers => {})
  end

  test "should filter by draft state" do
    presenter = AdminRootPresenter.new(:all)
    a = GuideEdition.create
    a.update_attribute(:state, 'draft')
    assert a.draft?

    b = GuideEdition.create
    b.update_attribute(:state, 'published')
    b.save
    b.reload
    assert !b.draft?

    assert_equal [a], presenter.draft.to_a
  end

  test "should filter by published state" do
    presenter = AdminRootPresenter.new(:all)

    a = GuideEdition.create
    assert !a.published?

    b = GuideEdition.create                                      
    b.update_attribute(:state, 'published')
    b.reload
    assert b.published?

    assert_equal [b], presenter.published.to_a
  end

  test "should filter by archived state" do
    presenter = AdminRootPresenter.new(:all)

    a = GuideEdition.create
    assert ! a.archived?

    b = GuideEdition.create
    b.editions.create!(state: 'archived')
    assert b.archived?

    assert_equal [b], presenter.archived.to_a
  end

  test "should filter by in_review state" do
    presenter = AdminRootPresenter.new(:all)
    user = User.create

    a = GuideEdition.create
    assert !a.in_review?

    b = GuideEdition.create
    b.update_attribute(:state, 'in_review')
    b.reload
    assert b.in_review?

    assert_equal [b], presenter.in_review.to_a
  end

  test "should filter by fact checking state" do
    presenter = AdminRootPresenter.new(:all)
    user = User.create

    a = GuideEdition.create
    assert !a.fact_check?

    b = GuideEdition.create
    b.update_attribute(:state, 'fact_check')
    b.reload
    assert b.fact_check?

    assert_equal [b], presenter.fact_check.to_a
  end

  test "should filter by lined up state" do
    presenter = AdminRootPresenter.new(:all)

    a = GuideEdition.create 
    a.update_attribute(:state, "lined_up")
    assert a.lined_up?

    b = GuideEdition.create  
    b.update_attribute(:state, "draft")
    b.reload
    assert !b.lined_up?

    assert_equal [a], presenter.lined_up.to_a
  end

  test "should select publications assigned to a user" do
    alice = User.create
    bob   = User.create

    a = GuideEdition.create
    assert_nil a.assigned_to
    assert a.lined_up?

    b = GuideEdition.create
    alice.assign(b, bob)
    assert_equal bob, b.assigned_to
    assert b.lined_up?

    presenter = AdminRootPresenter.new(bob)
    assert_equal [b], presenter.lined_up.to_a
  end

  test "should select publications assigned to nobody" do
    alice = User.create
    bob   = User.create

    a = GuideEdition.create!(title: 'My First Guide', panopticon_id: 1)
    assert_nil a.assigned_to
    assert a.lined_up?

    b = GuideEdition.create!(title: 'My Second Guide', panopticon_id: 2)
    alice.assign(b, bob)
    assert_equal bob, b.assigned_to
    assert b.lined_up?

    presenter = AdminRootPresenter.new(:nobody)
    assert_equal [a], presenter.lined_up.to_a
  end

  test "should select all publications" do
    alice = User.create
    bob   = User.create

    a = GuideEdition.create!(title: 'My First Guide')
    assert_nil a.assigned_to
    assert a.lined_up?

    b = GuideEdition.create!(title: 'My Second Guide')
    alice.assign(b, bob)
    assert_equal bob, b.assigned_to
    assert b.lined_up?

    presenter = AdminRootPresenter.new(:all)
    assert_equal [b, a].collect { |i| i.id.to_s }.sort, presenter.lined_up.to_a.collect { |i| i.id.to_s }.sort
  end

  test "should select and filter" do
    alice = User.create
    bob   = User.create

    a = GuideEdition.create
    assert_nil a.assigned_to
    assert a.lined_up?

    b = GuideEdition.create
    alice.assign(b, bob)
    assert_equal bob, b.assigned_to
    assert b.lined_up?

    c = GuideEdition.create
    c.update_attribute :state, 'published'
    alice.assign(c, bob)
    assert_equal bob, c.assigned_to
    assert !c.lined_up?

    presenter = AdminRootPresenter.new(bob)
    assert_equal [b], presenter.lined_up.to_a

    presenter = AdminRootPresenter.new(:nobody)
    assert_equal [a], presenter.lined_up.to_a

    presenter = AdminRootPresenter.new(:all)
    assert_equal [a, b], presenter.lined_up.to_a
  end

end
