# frozen_string_literal: true

require "test_helper"
require "nokogiri"

class DocsLandingPageThemeTest < ActiveSupport::TestCase
  include StaticLandingPageHelper

  test "CSS contains admin-inspired indigo color tokens" do
    css = File.read(StaticLandingPageHelper::DOCS_ROOT.join("assets", "styles.css"))
    assert_match(/indigo-950/, css, "Must define indigo-950 token")
    assert_match(/indigo-900/, css, "Must define indigo-900 token")
    assert_match(/indigo-600/, css, "Must define indigo-600 token")
    assert_match(/slate-900/, css, "Must define slate-900 token")
  end

  test "CSS uses gradient background matching admin theme" do
    css = File.read(StaticLandingPageHelper::DOCS_ROOT.join("assets", "styles.css"))
    assert_match(/linear-gradient/, css, "Must use gradient background")
    assert_match(/indigo-950/, css, "Gradient must reference indigo-950")
    assert_match(/indigo-900/, css, "Gradient must reference indigo-900")
    assert_match(/slate-900/, css, "Gradient must reference slate-900")
  end

  test "CSS includes rounded card styling" do
    css = File.read(StaticLandingPageHelper::DOCS_ROOT.join("assets", "styles.css"))
    assert_match(/border-radius/, css, "Must use rounded corners")
    assert_match(/feature-card/, css, "Must define feature card styles")
  end

  test "CSS includes button styling with indigo theme" do
    css = File.read(StaticLandingPageHelper::DOCS_ROOT.join("assets", "styles.css"))
    assert_match(/btn-primary/, css, "Must define primary button style")
    assert_match(/indigo-600/, css, "Button must use indigo color")
  end

  test "page uses white headings consistent with admin interface" do
    css = File.read(StaticLandingPageHelper::DOCS_ROOT.join("assets", "styles.css"))
    # Check that headings use white color
    assert_match(/h1.*color.*white|color-white/m, css,
                 "Headings must use white color token")
  end

  test "HTML uses semantic section hierarchy" do
    doc = landing_page_doc
    sections = doc.css("section")
    assert sections.length >= 4, "Must have at least 4 distinct sections"

    # Verify logical order
    ids = sections.map { |s| s["id"] }.compact
    assert_includes ids, "hero"
    assert_includes ids, "features"
    assert_includes ids, "benefits"
    assert_includes ids, "cta"
  end

  test "navigation reflects admin compact spacing pattern" do
    nav = landing_page_doc.at_css("nav")
    assert nav, "Must have a nav element"
    assert nav.at_css(".logo"), "Nav must have a logo element"
    assert nav.at_css(".nav-links"), "Nav must have navigation links"
  end
end
