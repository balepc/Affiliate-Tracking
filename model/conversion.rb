class Conversion
  include DataMapper::Resource

  property :id,           Serial
  property :referrer,     Text
  property :user_agent,   Text
  property :cookies,      Text
  property :ip,           Text
  property :created_at,   DateTime

  def self.connection
    @connection ||= PGconn.connect(PG_HOST, PG_PORT, '', '', PG_DATABASE, PG_USERNAME, PG_PASSWORD)
  end

  def self.by_date
    result = []
    db_res = connection.exec("select series.date, count(conversions.created_at)
        from (select generate_series(0,30) + date '#{Date.today - 30}' as date) as series
        left outer join conversions on series.date=DATE(conversions.created_at) group by series.date
        order by series.date;")
    db_res.each do |res|
      result << [res['date'], res['count']]
    end
    result
  end

end
