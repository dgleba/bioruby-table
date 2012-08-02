require 'uri'

module BioTable
  module RDF

    def RDF::namespaces
      """
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix : <http://biobeat.org/rdf/biotable/ns#>  .
      """
    end

    # Write a table header as Turtle RDF. 
    #
    # If we have a column name 'AXB1' the following gets written:
    #
    # [:AXB1 rdf:label "AXB1"; a :colname; :index 3 ].
    #
    # This method returns a list of these.
    def RDF::header(row)
      list = []
      raise "RDF expects unique column names!" if row != row.uniq
      row.each_with_index do | field,i |
        s = ":#{make_identifier(field)} rdf:label \"#{field}\" ; a :colname; :index #{i} ."
        list << s
      end
      list
    end

    # Write a table row as Turtle RDF
    #
    # If we have a row, each row element gets written with the header colname as an id, e.g.
    #
    # [:rs13475701 rdf:label "rs13475701"; a :rowname; :Chromosome 1 ; :Pos 0 ; :AXB1 "AA"].
    #
    # The method returns a String.

    def RDF::row(row, header)
      list = []
      rowname = make_identifier(row[0])
      list << ":#{rowname} rdf:label \"#{row[0]}\" ; a :rowname"
      row.each_with_index do | field,i |
        s = ":#{make_identifier(header[i])} "
        if BioTable::Filter.valid_number?(field)
          s += field.to_s
        else
          s += "\"#{field}\""
        end
        list << s
      end
      list.join(" ; ")+" ."
    end

    # Convenience class for writing RDF - tracks header values
    class Writer

      def initialize
        @rownames = {}
      end

      def write row, type
        if type == :header
          print RDF.namespaces
          @header = row.all_fields
          rdf = RDF.header(@header)
          print "# Table\n"
          print rdf.join("\n"),"\n\n"
        else
          if @rownames[row.rowname]
            raise "RDF expects unique row names! Duplicate #{row.rowname} found"
          else
            @rownames[row.rowname] = true
          end
          rdf = RDF.row(row.all_fields,@header)
          print rdf,"\n"
        end
      end
    end

private

    # An identifier is used for the subject and predicate in RDF. This is a case-sensitive
    # (shortened) URI. You can change default behaviour for identifiers using the options 
    # --transform-ids (i.e. in the input side, rather than the output side)
    #
    def RDF::make_identifier(s)
      clean_s = s.gsub(/[^[:print:]]/, '').gsub(/[#)(]/,"").gsub(/[%]/,"perc").gsub(/(\s|\.)+/,"_")
      valid_id = if clean_s =~ /^\d/
                   'r' + clean_s
                 else
                   clean_s
                 end
      valid_id
    end
  end

end