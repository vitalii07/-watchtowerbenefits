module DumpData
  def setup_test_projects
    sql = File.open(Rails.root.join('spec', 'fixtures', 'dump.sql'), 'rb') { |f| f.read }
    ActiveRecord::Base.connection.execute(sql)
  end
end
