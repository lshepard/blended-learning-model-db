require 'csv'
require 'innosight_report'

class InnosightCsvReport < InnosightReport
  def to_csv
    CSV.generate do |csv|
      csv << pretty_column_names
      value_rows.each do |cells|
        csv << cells
      end
    end
  end
end
