SpreeCurrentStockReport
=======================

Current stock report.

**SMALL CAVEAT: This is extracted from my own product in which I have added two custom fields to my `Spree::Product` class. Those being `barcode` and `enabled`. So this extension will probably not work out of the box for you. But you can fork it and remove references to those fields in the `SpreeCurrentStockReport::Report` class.**

Installation
------------

Add spree_current_stock_report to your Gemfile:

```ruby
gem 'spree_current_stock_report', github: "Hates/spree_current_stock_report"
```

Bundle your dependencies and run the installation generator:

```shell
bundle
bundle exec rails g spree_current_stock_report:install
```
