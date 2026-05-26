# frozen_string_literal: true

require "test_helper"
require "nokogiri"

class DocsLandingPageContentTest < ActiveSupport::TestCase
  include StaticLandingPageHelper

  # Hero messaging
  test "hero section communicates product purpose" do
    hero = landing_page_doc.at_css("#hero")
    assert hero, "Hero section must exist"

    heading = hero.at_css("h1")
    assert heading, "Hero must have an h1"
    assert_match(/fact/i, heading.text, "Hero heading must mention facts")
  end

  test "hero subtitle explains audience and value" do
    subtitle = landing_page_doc.at_css(".hero-subtitle")
    assert subtitle, "Hero must have a subtitle"
    text = subtitle.text.downcase
    assert_match(/content manager|product owner/i, text,
                 "Subtitle must mention target audience")
    assert_match(/fact/i, text, "Subtitle must reference fact management")
  end

  # English-only visible copy
  test "all visible text is in English" do
    body_text = landing_page_doc.at_css("body").text
    # Check for presence of common English words as a proxy
    assert_match(/features|manage|deliver|facts/i, body_text,
                 "Page must contain English marketing copy")
    assert_equal "en", landing_page_doc.at_css("html")["lang"],
                 "Document must declare lang=en"
  end

  # Feature highlights
  test "features section highlights core capabilities" do
    features = landing_page_doc.at_css("#features")
    assert features, "Features section must exist"

    cards = features.css(".feature-card")
    assert cards.length >= 3, "Must have at least 3 feature highlights"

    all_text = cards.map(&:text).join(" ").downcase
    assert_match(/curated/i, all_text, "Must highlight curated fact management")
    assert_match(/deliver/i, all_text, "Must highlight controlled delivery")
    assert_match(/api/i, all_text, "Must highlight API access")
  end

  test "feature highlights emphasize curated management and controlled delivery first" do
    cards = landing_page_doc.css("#features .feature-card")
    first_card_text = cards[0].text.downcase
    second_card_text = cards[1].text.downcase

    assert_match(/curated/i, first_card_text,
                 "First feature card must emphasize curated management")
    assert_match(/controlled|deliver/i, second_card_text,
                 "Second feature card must emphasize controlled delivery")
  end

  # Primary repository CTA
  test "primary CTA links to public GitHub repository" do
    assert_link_to "github.com/saumon/facthub"
  end

  test "CTA section has a clear call to action" do
    cta = landing_page_doc.at_css("#cta")
    assert cta, "CTA section must exist"

    link = cta.at_css("a[href*='github.com/saumon/facthub']")
    assert link, "CTA must contain a link to the GitHub repository"
    assert_match(/github/i, link.text, "CTA link must reference GitHub")
  end

  # Benefits section for content managers and product owners
  test "benefits section addresses content managers and product owners" do
    benefits = landing_page_doc.at_css("#benefits")
    assert benefits, "Benefits section must exist"

    text = benefits.text.downcase
    assert_match(/content manager/i, text, "Must address content managers")
    assert_match(/product owner/i, text, "Must address product owners")
  end
end
