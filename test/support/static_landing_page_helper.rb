# frozen_string_literal: true

# Shared helpers for static landing page tests.
# Provides methods to read and parse the docs/index.html file
# without requiring a running Rails server.
module StaticLandingPageHelper
  DOCS_ROOT = Rails.root.join("docs")
  INDEX_PATH = DOCS_ROOT.join("index.html")

  private

  def landing_page_html
    @landing_page_html ||= File.read(INDEX_PATH)
  end

  def landing_page_doc
    @landing_page_doc ||= Nokogiri::HTML5(landing_page_html)
  end

  def assert_section_exists(id, message = nil)
    msg = message || "Expected section with id='#{id}' to exist"
    assert landing_page_doc.at_css("##{id}"), msg
  end

  def assert_contains_text(text, message = nil)
    msg = message || "Expected landing page to contain '#{text}'"
    assert landing_page_html.include?(text), msg
  end

  def assert_link_to(href, message = nil)
    msg = message || "Expected landing page to contain a link to '#{href}'"
    link = landing_page_doc.css("a").find { |a| a["href"]&.include?(href) }
    assert link, msg
  end

  def assert_relative_asset(path, message = nil)
    msg = message || "Expected relative asset reference to '#{path}'"
    assert landing_page_html.include?(path), msg
  end
end
