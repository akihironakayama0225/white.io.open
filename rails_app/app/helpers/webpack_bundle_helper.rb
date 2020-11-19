require 'open-uri'
# webpackによるビルドファイル読み込み用ヘルパー
module WebpackBundleHelper
  class BundleNotFound < StandardError; end

  def javascript_bundle_tag(entry, **options)
    path = asset_bundle_path("#{entry}.js")
    logger.debug("-------------------")
    logger.debug(path)
    logger.debug("-------------------")

    options = {
      src: path,
      defer: true
    }.merge(options)

    # async と defer を両方指定した場合、ふつうは async が優先されるが、
    # defer しか対応してない古いブラウザの挙動を考えるのが面倒なので、両方指定は防いでおく
    options.delete(:defer) if options[:async]

    javascript_include_tag '', **options
  end

  def stylesheet_bundle_tag(entry, **options)
    path = asset_bundle_path("#{entry}.css")

    options = {
      href: path
    }.merge(options)

    stylesheet_link_tag '', **options
  end

  private
    # アセットが置かれているサーバーを返す
    def asset_server
      if  Rails.env === "development" then
        return "http://#{request.host}:3035/"
        #return "//#{request.host}/"
      else
        #return "//#{request.host}:3000/" # on the local
        return "//#{request.host}/" # on the heroku app
      end
    end

    def pro_manifest
      File.read('public/manifest.json')
    end

    def dev_manifest
      # webpack-dev-serverから直接取得する
      js_file_path = "#{asset_server}manifest.json"
      logger.debug("+++++++++++++++")
      logger.debug(js_file_path)
      logger.debug("+++++++++++++++")

      OpenURI.open_uri(js_file_path).read
    end

    def test_manifest
      File.read('public/javascripts-test/manifest.json')
    end

    def manifest
      return @manifest ||= JSON.parse(pro_manifest) if Rails.env.production?
      return @manifest ||= JSON.parse(dev_manifest) if Rails.env.development?
      return @manifest ||= JSON.parse(test_manifest)
    end

    def valid_entry?(entry)
      return true if manifest.key?(entry)
      raise BundleNotFound, "Could not find bundle with name #{entry}"
    end

    def asset_bundle_path(entry, **options)
      valid_entry?(entry)
      return asset_path("#{asset_server}" + manifest.fetch(entry), **options)
    end
end