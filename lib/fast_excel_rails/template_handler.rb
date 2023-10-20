require "action_view"

module FastExcelRails
  class TemplateHandler
    def default_format
      :xlsx
    end

    def call(template, source = nil)
      <<-eos
        # Expose FastExcel.open arguments as locals
        fast_excel_filename = defined?(fast_excel_filename).nil? ? nil : fast_excel_filename
        fast_excel_constant_memory = defined?(fast_excel_constant_memory).nil? ? false : fast_excel_constant_memory
        fast_excel_default_format = defined?(fast_excel_default_format).nil? ? nil : fast_excel_default_format

        # Only build one shared workbook object so partials can take advantage
        # of the same workbook by default.
        root_view = false
        unless @fast_excel_rails_template_workbook
          @fast_excel_rails_template_workbook = FastExcel.open(fast_excel_filename, constant_memory: fast_excel_constant_memory, default_format: fast_excel_default_format)
          root_view = true
        end

        # Define a local "workbook" variable for accessing things inside the
        # template.
        workbook = @fast_excel_rails_template_workbook
        #{source || template.source}

        if root_view
          @fast_excel_rails_template_workbook.read_string
        else
          ''
        end
      eos
    end
  end
end
