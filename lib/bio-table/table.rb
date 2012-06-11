module BioTable

  class Table

    attr_reader :header, :table, :rowname

    def initialize
      @logger = Bio::Log::LoggerPlus['bio-table']
      @table = []
      @rowname = []
    end

    # Read lines (list of string) and add them to the table, setting row names 
    # and row fields. The first row is assumed to be the header and ignored if the
    # header has been set.

    def read_lines lines, options = {}
      header = LineParser::parse(lines[0], options[:in_format])

      @header = header if not @header
      (lines[1..-1]).each do | line |
        fields = LineParser::parse(line, options[:in_format])
        @rowname << fields[0]
        @table << fields[1..-1] 
      end
      return self
    end

    def read_file filename, options = {}
      lines = []
      if not options[:in_format] and filename =~ /\.csv$/
        @logger.debug "Autodetected CSV file"
        options[:in_format] = :csv
      end
      @logger.debug(options)
      File.open(filename).each_line do | line |
        lines << line
      end
      read_lines(lines, options)
    end

    def write options = {}
      format = options[:format]
      format = :tab if not format
      formatter = FormatFactory::create(format)
      formatter.write(@header)
      each do | tablerow |
        # p tablerow
        formatter.write(tablerow.all_fields) if tablerow.valid?
      end
    end

    def [] row
      TableRow.new(@rowname[row],@table[row])
    end

    def each 
      @table.each_with_index do | row,i |
        yield TableRow.new(@rowname[i], row)
      end
    end

  end

  module TableReader
    def TableReader::read_file filename, options = {}
      logger = Bio::Log::LoggerPlus['bio-table']
      logger.info("Parsing #{filename}")
      t = Table.new
      t.read_file(filename, options)
      t
    end
  end

end
