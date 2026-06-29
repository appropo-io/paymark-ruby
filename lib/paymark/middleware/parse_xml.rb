# frozen_string_literal: true
require "faraday"
require "multi_xml"

module Paymark
  module Middleware
    # Faraday response middleware that parses XML bodies into a Hash using MultiXml.
    #
    # Replaces the `:xml` parser that faraday_middleware provided under Faraday 1.x,
    # which is unavailable under Faraday 2. Honours the same `:content_type` option,
    # e.g. `faraday.response :xml, content_type: /\bxml$/`.
    class ParseXml < Faraday::Middleware
      def initialize(app, options = {})
        super(app)
        @content_type = options[:content_type]
      end

      def on_complete(env)
        return unless process_response_type?(env)
        return if env.body.nil? || env.body.strip.empty?

        env.body = xml_parser.parse(env.body)
      end

      private

      # multi_xml renamed its top-level constant from MultiXml to MultiXML; support both.
      def xml_parser
        defined?(MultiXML) ? MultiXML : MultiXml
      end

      def process_response_type?(env)
        return true unless @content_type

        type = env.response_headers["Content-Type"].to_s.split(";", 2).first.to_s
        case @content_type
        when Regexp then type.match?(@content_type)
        when String then type == @content_type
        else true
        end
      end
    end
  end
end

Faraday::Response.register_middleware(xml: Paymark::Middleware::ParseXml)
