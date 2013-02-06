require 'innosight_report'
require 'erubis'

class InnosightXlsReport < InnosightReport
  # For some reason this does not work in Numbers.app, not sure about Excel.
  # I got the approach from here:
  # http://railscasts.com/episodes/362-exporting-csv-and-excel?view=asciicast
  #
  # Confirmed in the comments that it does not work in Numbers
  # http://railscasts.com/episodes/362-exporting-csv-and-excel?view=comments
  #
  # Maybe try https://github.com/randym/axlsx for a universal file.
  def to_xls
    erb = <<-TEMPLATE
<?xml version="1.0"?>
<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
  xmlns:o="urn:schemas-microsoft-com:office:office"
  xmlns:x="urn:schemas-microsoft-com:office:excel"
  xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
  xmlns:html="http://www.w3.org/TR/REC-html40">
  <Worksheet ss:Name="Sheet1">
    <Table>
      <Row>
        <% pretty_column_names.each do |column_name| %>
          <Cell><Data ss:Type="String"><%= column_name %></Data></Cell>
        <% end %>
      </Row>
    <% value_rows.each do |cells| %>
      <Row>
        <% cells.each do |cell| %>
          <Cell><Data ss:Type="String"><%= cell %></Data></Cell>
        <% end %>
      </Row>
    <% end %>
    </Table>
  </Worksheet>
</Workbook>
    TEMPLATE

    Erubis::Eruby.new(erb).evaluate(self)
  end
end
