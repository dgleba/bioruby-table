@cli
Feature: Command-line interface (CLI)

  bio-table has a powerful command line interface. Here we regression test features.

  Scenario: Test the numerical filter by indexed column values
    Given I have input file(s) named "test/data/input/table1.csv"
    When I execute "./bin/bio-table --num-filter 'values[3] > 0.05'"
    Then I expect the named output to match "table1-0_05"

  Scenario: Test the numerical filter by column names
    Given I have input file(s) named "test/data/input/table1.csv"
    When I execute "./bin/bio-table --num-filter 'axb2 > 0.05'"
    Then I expect the named output to match "table1-named-0_05"

  Scenario: Test the filter by indexed column values
    Given I have input file(s) named "test/data/input/table1.csv"
    When I execute "./bin/bio-table --filter 'fields[3] =~ 0.1'"
    Then I expect the named output to match "table1-filter-0_1"

  Scenario: Test the filter by column names
    Given I have input file(s) named "test/data/input/table1.csv"
    When I execute "./bin/bio-table --filter 'axb1 =~ /0.1/'"
    Then I expect the named output to match "table1-filter-named-0_1"

  Scenario: Reduce columns
    Given I have input file(s) named "test/data/input/table1.csv"
    When I execute "./bin/bio-table test/data/input/table1.csv --columns '#Gene,AJ,B6,Axb1,Axb4,AXB13,Axb15,Axb19'"
    Then I expect the named output to match "table1-columns"

  Scenario: Reduce columns by index number
    Given I have input file(s) named "test/data/input/table1.csv"
    When I execute "./bin/bio-table test/data/input/table1.csv --columns 0,1,8,2,4,6"
    Then I expect the named output to match "table1-columns-indexed"

  Scenario: Reduce columns by regex
    Given I have input file(s) named "test/data/input/table1.csv"
    When I execute "./bin/bio-table test/data/input/table1.csv --column-filter 'colname !~ /ax/i'"
    Then I expect the named output to match "table1-columns-regex"

  Scenario: Rewrite rownames
    Given I have input file(s) named "test/data/input/table1.csv"
    When I execute "./bin/bio-table test/data/input/table1.csv --rewrite 'rowname = field[2]; field[1]=nil if field[2].to_f<0.25'"
    Then I expect the named output to match "table1-rewrite-rownames"

  Scenario: Write RDF format
    Given I have input file(s) named "test/data/input/table1.csv"
    When I execute "./bin/bio-table --format rdf --transform-ids downcase"
    Then I expect the named output to match "table1-rdf1"

  Scenario: Write HTML format
    Given I have input file(s) named "test/data/input/table1.csv"
    When I execute "./bin/bio-table --format eval -e '"<tr><td>"+field.join("</td><td>")+"</td></tr>"'"
    Then I expect the named output to match "table1-html"

  Scenario: Write LaTeX format
    Given I have input file(s) named "test/data/input/table1.csv"
    When I execute "./bin/bio-table --columns gene_symbol,gene_desc --format eval -e 'field.join(" & ")+" \\\\"'"
    Then I expect the named output to match "table1-latex"

  Scenario: Merge tables horizontally
    Given I have input file(s) named "test/data/input/table1.csv"
    When I execute "./bin/bio-table --merge test/data/input/table2.csv"
    Then I expect the named output to match "table1-merge"

  Scenario: Merge tables vertically
    Given I have input file(s) named "test/data/input/table1.csv"
    When I execute "./bin/bio-table test/data/input/table2.csv"
    Then I expect the named output to match "table1-append"

  Scenario: Diff tables
    Given I have input file(s) named "test/data/input/table1.csv"
    When I execute "./bin/bio-table --diff test/data/input/table2.csv"
    Then I expect the named output to match "table1-diff"

  Scenario: Read from STDIN
    Given I have input file(s) named "test/data/input/table1.csv"
    When I execute "cat test/data/input/table1.csv|./bin/bio-table test/data/input/table1.csv --rewrite 'rowname = field[2]; field[1]=nil if field[2].to_f<0.25'"
    Then I expect the named output to match "table1-STDIN"

  Scenario: Use special string splitter
    Given I have input file(s) named "test/data/input/table_split_on.txt"
    When I execute "./bin/bio-table test/data/input/table_split_on.txt --in-format split --split-on ','"
    Then I expect the named output to match "table_split_on_string"

  Scenario: Use special regex splitter
    Given I have input file(s) named "test/data/input/table_split_on.txt"
    When I execute "./bin/bio-table test/data/input/table_split_on.txt --in-format regex --split-on '\s*,'"
    Then I expect the named output to match "table_split_on_regex"

  Scenario: Use header in filter
    Given I have input file(s) named "test/data/input/table_no_headers.txt"
    When I execute "./bin/bio-table --in-format split --split-on ',' --num-filter 'values[1]!=0' --with-headers" 
    Then I expect the named output to match "table_filter_headers"

  Scenario: Use count in filter
    Given I have input file(s) named "test/data/input/table1.csv"
    When I execute "./bin/bio-table --num-filter 'values.compact.max >= 10.0 and values.compact.count{|x| x>=3.0} > 3'"
    Then I expect the named output to match "table_counter_filter"
