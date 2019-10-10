# frozen_string_literal: true

class PlaceholderPath
  def initialize(path_definition)
    @path_definition = path_definition
  end

  # Returns a filepath with {locale_code} placeholder e.g. for the parameters
  # path:             "/locales/de/admin/index.de.po"
  # path_definition:  "/locales/{locale_code}/**/*{locale_code}.po"
  # locale_code:      "de"
  # it will return:   "/locales/{locale_code}/admin/index.{locale_code}.po"
  def for_path(path, locale_code)
    regex = regex(locale_code)
    path.match(regex).captures.join('{locale_code}')
  end

  private

    # Replaces UNIX wildcards in a path definition and returns a regular
    # expression of the path definition
    # e.g. "/config/**/*{locale_code}.po"  => /\/config\/.*de\.po/
    #
    # (1) - Replaces ** and * wildcards with .*
    # (2) - Replaces duplicate wildcards like .*/.* with one .*
    # (3) - splits path_definition at {locale_code}
    # (4) - Puts each part of splits in parantesis and joins them with locale_code
    def regex(locale_code)
      string = @path_definition

      string = string.gsub(/\./, '\.')
      string = string.gsub(/((?<!\*)\*(?!\*))|(\*\*)/, '.*') # (1)
      string = string.gsub('.*/.*', '.*') # (2)

      splits = string.split('{locale_code}') # (3)
      path = splits.map { |segment| "(#{segment})" }.join(locale_code) # (4)

      Regexp.new(path, Regexp::IGNORECASE)
    end
end
