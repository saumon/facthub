# frozen_string_literal: true

require "test_helper"
require "nokogiri"

class DocsLandingPageContractTest < ActiveSupport::TestCase
  include StaticLandingPageHelper

  test "docs/index.html exists as the static entry point" do
    assert File.exist?(INDEX_PATH), "Expected docs/index.html to exist"
  end

  test "uses relative asset paths for stylesheet" do
    assert_relative_asset "./assets/styles.css"
  end

  test "uses relative asset paths for script" do
    assert_relative_asset "./assets/app.js"
  end

  test "stylesheet file exists on disk" do
    assert File.exist?(DOCS_ROOT.join("assets", "styles.css")),
           "Expected docs/assets/styles.css to exist"
  end

  test "does not reference Rails helpers or server-rendered templates" do
    refute landing_page_html.include?("<%="), "Page must not use ERB tags"
    refute landing_page_html.include?("csrf"), "Page must not reference CSRF tokens"
    refute landing_page_html.include?("importmap"), "Page must not use Rails importmap"
  end

  test "page has required navigation sections" do
    assert_section_exists "header"
    assert_section_exists "hero"
    assert_section_exists "features"
    assert_section_exists "benefits"
    assert_section_exists "cta"
    assert_section_exists "footer"
  end

  test "core content is available without JavaScript" do
    # All content sections are in the static HTML
    doc = landing_page_doc
    assert doc.at_css("#hero h1"), "Hero heading must exist in static HTML"
    assert doc.at_css("#features .feature-card"), "Feature cards must exist in static HTML"
    assert doc.at_css("#cta a[href]"), "CTA link must exist in static HTML"
  end

  test "page renders valid HTML5 document structure" do
    assert landing_page_html.start_with?("<!DOCTYPE html>"), "Must be HTML5 doctype"
    doc = landing_page_doc
    assert_equal "en", doc.at_css("html")["lang"], "Must declare lang=en"
    assert doc.at_css("meta[charset]"), "Must have charset meta"
    assert doc.at_css("meta[name='viewport']"), "Must have viewport meta"
  end
end
