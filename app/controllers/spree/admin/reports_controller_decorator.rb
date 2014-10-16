Spree::Admin::ReportsController.class_eval do
  helper 'spree/base'

  before_action do
    self.class.add_available_report!(:current_stock_report)
  end

  def current_stock
    report = SpreeCurrentStockReport::Report.generate
    report_name = "current-stock-report.csv"
    report_type = "text/csv"

    send_data report.to_csv, filename: report_name, type: report_type
  end
end
