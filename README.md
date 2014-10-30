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

## Demo

Below is a sample test.csv file

```
Year ID,Make ID,Model ID,Description ID,Price ID
1997,Ford,E350,"ac, abs, moon","3000.00"
1999,Chevy,"Venture ""Extended Edition""",,4900.00
1999,"Chevy","Venture ""Extended Edition, Very Large""","",5000.00
1996,Jeep,Grand Che'rokee,"MUST SELL!air, moon roof, loaded",4799.00
```
To get the data analysis of above file, you can use CsvImportAnalyzer to process the file.

```ruby
metadata = CsvImportAnalyzer.process("test.csv", {:distinct => 2})
```
### Result

```javascript
{
  "csv_file": {
    "filename": "sampleTab.csv",
    "file_size": 276,
    "record_delimiter": ",",
    "rows": 6,
    "columns": 5,
    "processed_filename": "processed_sampleTab.csv",
    "processed_file_path": "/tmp/processed_sampleTab.csv",
    "processed_file_size": 279,
    "error_report": "/tmp/error_report_sampleTab.csv"
  },
  "data_manipulations": {
    "replace_nulls": true,
    "replace_quotes": true
  },
  "csv_headers": {
    "year_id": {
      "datatype": "int",
      "datatype_analysis": {
        "int": 4
      },
      "distinct_values": [
        1997,
        1999,
        1996
      ]
    },
    "make_id": {
      "datatype": "string",
      "datatype_analysis": {
        "string": 4
      },
      "distinct_values": [
        "Ford",
        "Chevy",
        "Jeep"
      ]
    },
    "model_id": {
      "datatype": "string",
      "datatype_analysis": {
        "string": 4
      },
      "distinct_values": "3+"
    },
    "description_id": {
      "datatype": "string",
      "datatype_analysis": {
        "string": 2
      },
      "distinct_values": [
        "ac, abs, moon",
        "MUST SELL!air, moon roof, loaded"
      ],
      "nullable": true
    },
    "price_id": {
      "datatype": "float",
      "datatype_analysis": {
        "float": 4
      },
      "distinct_values": "3+"
    }
  },
  "sql": {
    "pg": {
      "create_query": "create table processed_sampletab.csv ( year_id int not null, make_id varchar(255) not null, model_id varchar(255) not null, description_id varchar(255), price_id float not null);",
      "import_query": "COPY processed_sampletab.csv FROM '/tmp/processed_sampleTab.csv' HEADER DELIMITER ',' CSV NULL AS 'NULL';"
    },
    "mysql": {
      "create_query": "create table processed_sampletab.csv ( year_id int not null, make_id varchar(255) not null, model_id varchar(255) not null, description_id varchar(255), price_id float not null);",
      "import_query": "COPY processed_sampletab.csv FROM '/tmp/processed_sampleTab.csv' HEADER DELIMITER ',' CSV NULL AS 'NULL';"
    }
  }
}

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

