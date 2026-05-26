# frozen_string_literal: true

require "test_helper"
require "nokogiri"

class DocsLandingPageResponsiveTest < ActiveSupport::TestCase
  include StaticLandingPageHelper

  test "viewport meta tag is present with mobile-safe settings" do
    meta = landing_page_doc.at_css("meta[name='viewport']")
    assert meta, "Must have a viewport meta tag"
    content = meta["content"]
    assert_match(/width=device-width/i, content, "Must set width=device-width")
    assert_match(/initial-scale=1/i, content, "Must set initial-scale=1")
  end

  test "page structure uses mobile-safe container pattern" do
    containers = landing_page_doc.css(".container")
    assert containers.length >= 4,
           "Must have container wrappers for responsive layout control"
  end

  test "all asset references are relative" do
    doc = landing_page_doc

    # Check stylesheet links
    doc.css("link[rel='stylesheet']").each do |link|
      href = link["href"]
      refute href&.start_with?("/"), "Stylesheet href must be relative: #{href}"
      refute href&.start_with?("http"), "Stylesheet href must not be absolute: #{href}"
    end

    # Check script sources
    doc.css("script[src]").each do |script|
      src = script["src"]
      refute src&.start_with?("/"), "Script src must be relative: #{src}"
      refute src&.start_with?("http"), "Script src must not be absolute: #{src}"
    end
  end

  test "CSS includes responsive breakpoints" do
    css = File.read(StaticLandingPageHelper::DOCS_ROOT.join("assets", "styles.css"))
    assert_match(/@media/, css, "CSS must include media queries")
    assert_match(/max-width:\s*768px/i, css, "CSS must include mobile breakpoint")
  end

  test "mobile menu toggle exists for small viewports" do
    toggle = landing_page_doc.at_css(".mobile-menu-toggle")
    assert toggle, "Must have a mobile menu toggle button"
    assert_equal "Toggle navigation menu", toggle["aria-label"],
                 "Mobile toggle must have an accessible label"
  end

  test "script is deferred to avoid render blocking" do
    script = landing_page_doc.at_css("script[src*='app.js']")
    assert script, "Must reference app.js"
    assert script["defer"] || script["async"],
           "Script must be deferred or async to avoid blocking first render"
  end
end
