require "crystal-gql"
require "base64"
require "json"

module Golurker
  module Go
    SITES = %w(
albertslundbibliotek.dk
bib.ballerup.dk
bib.kulturrummet.dk
bibl.frederikshavn.dk
bibliotek.brk.dk
bibliotek.holbaek.dk
bibliotek.htk.dk
bibliotek.kk.dk
bibliotek.samsoe.dk
bibliotekerne.halsnaes.dk
biblioteket.horsholm.dk
biblioteket.laesoe.dk
biblioteket.sonderborg.dk
billundbib.dk
delingstjenesten.dk
egedalbibliotekerne.dk
favrskovbib.dk
fkb.dk
fmbib.dk
fredericiabib.dk
furbib.dk
genbib.dk
gladbib.dk
guldbib.dk
haderslevbibliotekerne.dk
hedenstedbib.dk
helsbib.dk
hilbib.dk
hjbib.dk
horsensbibliotek.dk
kertemindebibliotekerne.dk
koldingbib.dk
kulturogborgerhus.vallensbaek.dk
langelandbibliotek.dk
lejrebib.dk
lollandbib.dk
mfbib.dk
norddjursbib.dk
odsbib.dk
ringstedbib.dk
riskbib.dk
rudbib.dk
silkeborgbib.dk
solbib.dk
svendborgbibliotek.dk
syddjursbibliotek.dk
taarnbybib.dk
vejbib.dk
vejlebib.dk
viborgbib.dk
www.aabenraabib.dk
www.aakb.dk
www.aalborgbibliotekerne.dk
www.arrebib.dk
www.assensbib.dk
www.bbs.fo
www.bibliotek.alleroed.dk
www.bibliotek.odder.dk
www.bibliotek.skanderborg.dk
www.bibliotekerne.frederikssund.dk
www.bibliotekmorsoe.dk
www.brondby-bibliotekerne.dk
www.bronderslevbib.dk
www.dcbib.dk
www.drabib.dk
www.esbjergbibliotek.dk
www.faxebibliotek.dk
www.fredensborgbibliotekerne.dk
www.glostrupbib.dk
www.grevebibliotek.dk
www.gribskovbib.dk
www.herlevbibliotek.dk
www.herningbib.dk
www.holstebrobibliotek.dk
www.hvidovrebib.dk
www.ikast-brandebibliotek.dk
www.ishojbib.dk
www.kalundborgbib.dk
www.koegebib.dk
www.lyngbybib.dk
www.middelfartbibliotek.dk
www.naesbib.dk
www.nordfynsbib.dk
www.nyborgbibliotek.dk
www.odensebib.dk
www.randersbib.dk
www.rdb.dk
www.rebildbib.dk
www.roskildebib.dk
www.skivebibliotek.dk
www.soroebib.dk
www.stevnsbib.dk
www.struerbibliotek.dk
www.vardebib.dk
www.vhbib.dk
www.vordingborgbibliotekerne.dk
    )

    QUERY = "query MyQuery($uuid: ID!) {\n  node(id: $uuid) {\n    ... on NodeGoPage {\n      changed {\n        timestamp\n      }\n    }\n  }\n}"

    def self.get_frontpage_timestamp(hostname : String) : Int32
      user = ENV["BNF_USER"]? || raise "BNF_USER env variable not set"
      pass = ENV["BNF_PASS"]? || raise "BNF_PASS env variable not set"
      basic_auth = Base64.strict_encode("#{user}:#{pass}")

      api = GraphQLClient.new "https://#{hostname}/graphql"
      api.add_header("Authorization", "Basic #{basic_auth}")

      begin
        data, error, loading = api.query(QUERY, {"uuid" => "d5330804-5682-4471-a428-1d058c117740"})
      rescue
        raise "Exception in GraphQL call, is creds valid?"
      end

      raise "GraphQL error: #{error}" if error

      timestamp = data.dig?("node", "changed", "timestamp")

      raise "No frontpage?" unless timestamp

      timestamp = timestamp.as_i

      timestamp
    end

  end
end
