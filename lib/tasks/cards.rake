namespace :cards do
  task export_to_yaml: :environment do
    ARGV.shift
    file_path = ARGV.shift || File.join(Rails.root, 'data/cards.yml')
    Card.export_to_file
  end

  task batch_rename: :environment do
    SOURCE_PATH = '/Users/brian/Downloads/pages/All\ Queen\'s\ Blood\ Cards\ In\ Final\ Fantasy\ 7\ Rebirth_files'
    DETAILED_CARDS_PATH = File.join(Rails.root, 'app/assets/images/detailed_cards/')
    CARD_FILENAME_REGEXP = /^(final-fantasy-(7|vii)-rebirth-)([a-z0-9\-]+)(\.|_\d+\.)avif$/i

    dash_id_to_filenames = {}
    missing_card_dash_ids = {}

    dash_id_to_card_id = {}
    Card.all.each do |card|
      dash_id_to_card_id[card.dash_id] = card
    end
    Dir.glob(File.join(SOURCE_PATH, '*.avif')).each do |file_path|
      file_name = File.basename(file_path)
      m = file_name.match(CARD_FILENAME_REGEXP)
      # puts "#{file_name} => #{m.inspect}"
      next if m.nil?

      dash_id = m[3]
      # puts '%40s | %s' % [dash_id, file_name]
      dash_id_to_filenames[dash_id] ||= []
      dash_id_to_filenames[dash_id] << file_name
      if (card = dash_id_to_card_id[dash_id])
        # FileUtils.cp(file_path, DETAILED_CARDS_PATH + file_name)
        biggest_path = Dir.glob(File.join(SOURCE_PATH, "#{m[1]}#{dash_id}*")).sort_by do |version_path|
          File.size(version_path)
        end.last
        puts '  %30s | %f' % ["#{File.basename(biggest_path)}", File.size(biggest_path) / 1024.0]
        FileUtils.cp(biggest_path, DETAILED_CARDS_PATH + card.card_number.to_s + '.avif') unless File.exist?(DETAILED_CARDS_PATH + card.card_number.to_s + '.avif')
      else
        missing_card_dash_ids[dash_id] = file_name
      end
    end
    puts '=' * 50
    puts "dash_id_to_filenames: #{dash_id_to_filenames.size}"
    puts "Missing cards: #{missing_card_dash_ids.size}: #{missing_card_dash_ids.keys.join(', ')}"
  end
end