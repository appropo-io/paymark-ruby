# frozen_string_literal: true

require "test_helper"

class ParseXmlTest < Minitest::Test
  def parse(body, content_type: "application/xml", matcher: /\bxml$/)
    middleware = Paymark::Middleware::ParseXml.new(->(env) { env }, content_type: matcher)
    env = Struct.new(:body, :response_headers).new(body, { "Content-Type" => content_type })
    middleware.on_complete(env)
    env.body
  end

  def test_parses_matching_xml_into_a_hash
    assert_equal({ "Root" => { "a" => "1" } }, parse("<Root><a>1</a></Root>"))
  end

  def test_leaves_non_matching_content_type_untouched
    body = "<Root/>"
    assert_equal body, parse(body, content_type: "application/json")
  end

  def test_ignores_charset_in_content_type
    assert_equal({ "Root" => nil }, parse("<Root/>", content_type: "application/xml; charset=utf-8"))
  end

  def test_leaves_empty_body_untouched
    assert_equal "", parse("")
  end
end
