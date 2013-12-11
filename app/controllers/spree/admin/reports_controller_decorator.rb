Spree::Admin::ReportsController.class_eval do
  helper 'spree/base'

  before_filter do
    Spree::Admin::ReportsController::AVAILABLE_REPORTS.merge!({
      current_stock: { name: Spree.t(:current_stock_report).html_safe + %{ <i class="icon-table"></i>}.html_safe, description: Spree.t(:current_stock_report_description) },
    })
  end

  def current_stock
    report = SpreeCurrentStockReport::Report.generate
    report_name = "current-stock-report.csv"
    report_type = "text/csv"

    send_data report.to_csv, filename: report_name, type: report_type
  end
end
