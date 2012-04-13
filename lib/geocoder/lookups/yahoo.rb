require 'geocoder/lookups/base'
require "geocoder/results/yahoo"

module Geocoder::Lookup
  class Yahoo < Base

    def map_link_url(coordinates)
      "http://maps.yahoo.com/#lat=#{coordinates[0]}&lon=#{coordinates[1]}"
    end

    private # ---------------------------------------------------------------

    def results(query, reverse = false)
      return [] unless doc = fetch_data(query, reverse)
      conf = Geocoder::Configuration
      if doc = doc['ResultSet'] and doc['Error'] == 0
        if conf.limit_to_country
          country = conf.country.to_s.upcase
          doc['Results'] = doc['Results'].select do |r|
            r and r['countrycode'].to_s.upcase == country
          end
          doc['Found'] = doc['Results'].size
        end
        return doc['Found'] > 0 ? doc['Results'] : []
      else
        warn "Yahoo Geocoding API error: #{doc['Error']} (#{doc['ErrorMessage']})."
        return []
      end
    end

    def query_url(query, reverse = false)
      conf = Geocoder::Configuration
      gflags = %w[A C]
      reverse and gflags << 'R'
      conf.limit_to_country and gflags << 'L'
      params = {
        :location => query,
        :flags    => "JXTSR",
        :gflags   => gflags * '',
        :locale   => "#{conf.language}_#{conf.country}",
        :appid    => conf.api_key
      }
      "http://where.yahooapis.com/geocode?" + hash_to_query(params)
    end
  end
end
