module SpreeCurrentStockReport
  class Report

    START_DATE = Date.parse("1/1/2013")

    def self.generate
      new.generate
    end

    def generate
      report_columns = [
        "Variant ID",
        "SKU",
        "Barcode",
        "Enabled",
        "Brand",
        "Name",
        "Variant",
        "Size",
        "Current Stock",
        "Sales (Total)",
        "Sales (Past 30 Days)",
        "Sales (Per Month Avg.)",
        "Opt. Order Qty",
        "Cost",
        "Total Cost",
        "Price",
        "Total Price"
      ]

      totals = {}
      line_items = Spree::Order.complete.ransack(created_at_gt: START_DATE.to_s(:sql)).result.collect(&:line_items).flatten
      line_items.each do |line_item|
        next if line_item.variant.deleted?

        variant = line_item.variant
        totals[variant.id] = { variant: variant, quantity_sold: 0 } unless totals[variant.id]
        totals[variant.id][:quantity_sold] += line_item.quantity
      end

      thirty_day_totals = {}
      line_items = Spree::Order.complete.ransack(created_at_gt: 30.days.ago.to_s(:sql)).result.collect(&:line_items).flatten
      line_items.each do |line_item|
        next if line_item.variant.deleted?

        variant = line_item.variant
        thirty_day_totals[variant.id] = { variant: variant, quantity_sold: 0 } unless thirty_day_totals[variant.id]
        thirty_day_totals[variant.id][:quantity_sold] += 1
      end

      report = Table report_columns

      variants = Spree::Variant.includes(:product).where("spree_products.deleted_at IS NULL")
      variants.each do |v|
        on_hand = v.total_on_hand || 0
        cost = v.cost_price || BigDecimal.new("0.0")
        price = v.price || BigDecimal.new("0.0")

        total = totals[v.id]
        sold = total ? total[:quantity_sold] : 0

        thirty_day_total = thirty_day_totals[v.id]
        thirty_day_sold = thirty_day_total ? thirty_day_total[:quantity_sold] : 0

        report_attributes = []
        report_attributes << v.id
        report_attributes << "'#{v.sku}'"
        report_attributes << "'#{v.barcode}'"
        report_attributes << v.product.enabled
        report_attributes << v.product.brand_taxon_root.try(:name)
        report_attributes << v.product.name
        report_attributes << v.options_text
        report_attributes << v.size
        report_attributes << on_hand

        if total
          report_attributes <<(sold)
        else
          report_attributes << "0"
        end

        if thirty_day_total
          report_attributes <<(thirty_day_sold)
        else
          report_attributes << "0"
        end

        if total
          current_date = Time.zone.now
          number_of_months = (current_date.year * 12 + current_date.month) - (START_DATE.year * 12 + START_DATE.month)
          sold_per_month = sold.to_f / number_of_months 

          report_attributes <<(sold_per_month).round(2)
          report_attributes <<(sold_per_month - on_hand).round(2)
        else
          report_attributes << "0"
          report_attributes << "0"
        end

        report_attributes << cost.to_s
        report_attributes << (cost * BigDecimal.new(on_hand.to_s)).to_s
        report_attributes << price.to_s
        report_attributes << (price * BigDecimal.new(on_hand.to_s)).to_s

        report << report_attributes
      end

      report
    end

  end
end
