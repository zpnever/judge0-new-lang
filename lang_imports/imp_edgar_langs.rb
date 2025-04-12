require_relative 'edgar_langs/edg_lang_id_start'
require_relative 'edgar_langs/oop'
require_relative 'edgar_langs/cmc'

@languages ||= []

@edgar_langs.each_with_index do |lang, index|
        @languages << {id: @start + index + 1, name: lang[:name], is_archived: lang[:is_archived], source_file: lang[:source_file], compile_cmd: lang[:compile_cmd], run_cmd: lang[:run_cmd]}
end
