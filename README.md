# Csv::Import::Analyzer

Perform datatype analysis on desired chunk
Calculate min-max bounds for each column
Determine which coulmns are nullable in the csv file

Note: This gem expects the first line to be definitve header, as in like column names if the csv file has to be imported to database.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'csv-import-analyzer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install csv-import-analyzer

## Usage

Calling process on a filename would generate a metadata_output.json which has the Delimiter, Datatype Analysis and SQL (create and import) statements for both PostgreSQL and MySQL

```ruby

  CsvImportAnalyzer.process(filename)
  
```

## TODO:
  <ul>
    <li> Handle control of processed input file to user </li>
    <li> Return the analysis as Json object.</li>
    <li> Better - Structuring the analysis outputted to csv</li>
    <li> Add support to convert and import xlsx files to csv </li>
  </ul>

## Additional Information

### Dependencies
  <ul><li><a href="https://github.com/tilo/smarter_csv">smarter_csv</a> - For processing the csv in chunks</li></ul>
  
## Contributing

1. Fork it ( https://github.com/avinash-vllbh/csv-import-analyzer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
