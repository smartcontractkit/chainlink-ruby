module SpecHelpers
  def sem_rush_error_50
    http_response body: 'ERROR 50 :: NOTHING FOUND'
  end

  def sem_rush_phrase_organic_bitcoin(options = {})
    domain = options[:domain] || Faker::Internet.domain_name
    http_response body: <<CSV
Domain;Url
bitcoin.org;https://bitcoin.org/
#{domain};https://en.wikipedia.org/wiki/Bitcoin
bitcoin.com;https://www.bitcoin.com/
coindesk.com;http://www.coindesk.com/price/
coindesk.com;http://www.coindesk.com/information/what-is-bitcoin/
wired.com;http://www.wired.com/2011/11/mf_bitcoin/
forbes.com;http://www.forbes.com/sites/kashmirhill/2013/05/09/25-things-i-learned-about-bitcoin-from-living-on-it-for-a-week/
newyorker.com;http://www.newyorker.com/magazine/2011/10/10/the-crypto-currency
weusecoins.com;https://www.weusecoins.com/
cnn.com;http://money.cnn.com/infographic/technology/what-is-bitcoin/
CSV
  end

  def sem_rush_list_projects
    [{
      "keywords": [{
        "keyword": "smart contract",
        "tags": [],
        "timestamp": 1446228184
      }],
      "competitors": [],
      "tools": [],
      "project_id": 154634,
      "project_name": "8db311e070582f140d307a36d73ebe21",
      "url": "smartcontract.com"
    },
    {
      "keywords": [{
        "keyword": "smart contract",
        "tags": [],
        "timestamp": 1446232147
      }],
      "competitors": [],
      "tools": [],
      "project_id": 154672,
      "project_name": "787629dec19e0c8f869d19e8766ba8de",
      "url": "smartcontract.com"
    }].to_json
  end

  def sem_rush_project_response(options = {})
    key_word = options[:key_word] || Faker::Company.catch_phrase
    url = options[:url] || Faker::Internet.domain_name
    name = options[:name] || SecureRandom.name
    id = options[:id] || Random.rand(1_000_000)

    {
      "keywords": [
        {
          "keyword": key_word,
          "tags": [],
          "timestamp": 1446232147
        }
      ],
      "competitors": [],
      "tools": [],
      "project_id": id.to_i,
      "project_name": name,
      "url": url
    }.to_json
  end

  def sem_rush_position_tracking(options = {})
    phrase = options[:phrase] || Faker::Company.catch_phrase
    ranking = options[:ranking] || "n/a"
    date = options[:date] || Time.now.utc.strftime("%Y%m%d")
    domain = "*.#{options[:domain] || Faker::Internet.domain_name}/"

    http_response body: {
      "data": {
        "0": {
          "Be": "",
          "Cp": "n/a",
          "Fi": "",
          "Nq": "n/a",
          "Ph": phrase,
          "Pi": "6009114640844893555",
          "Tg": {},
          "Dt": {
            "20151026": { domain => "n/a" },
            "20151027": { domain => "n/a" },
            "20151028": { domain => "n/a" },
            "20151029": { domain => "n/a" },
            "20151030": { domain => "n/a" },
            "20151031": { domain => "n/a" },
            "20151101": { domain => "n/a" },
            date => { domain => ranking }
          },
          "Lt": {
            "20151026": { domain => "org" },
            "20151027": { domain => "org" },
            "20151028": { domain => "org" },
            "20151029": { domain => "org" },
            "20151030": { domain => "org" },
            "20151031": { domain => "org" },
            "20151101": { domain => "org" },
            date => { domain => "org"}
          },
          "Diff": { domain => ""},
          "Diff1": { domain => ""},
          "Diff7": { domain => ""},
          "Diff30": { domain => ""}
        }
      },
      "limit": "10",
      "offset": "0",
      "server": "USA2",
      "total": "1",
    }.to_json
  end
end
