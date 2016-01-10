require_relative 'asset_path_tag'
require 'shellwords'

module Jekyll
  class ImageTag < Jekyll::AssetPathTag
    def initialize(tag_name, markup, tokens)
      markup, @alt_text = Shellwords.shellsplit(markup)
      super tag_name, markup, tokens
    end

    def render(context)
      asset_url = super

      html = <<-HTML
      <a href="#{asset_url}"><img
          src="#{asset_url}"
          alt="#{@alt_text}"
          title="#{@alt_text}"
      ></a>
      HTML
      html.strip
    end
  end
end

Liquid::Template.register_tag('image', Jekyll::ImageTag)
