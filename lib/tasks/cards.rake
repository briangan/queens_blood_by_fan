namespace :cards do
  task export_to_yaml: :environment do
    ARGV.shift
    file_path = ARGV.shift || File.join(Rails.root, 'data/cards.yml')
    Card.export_to_file
  end
end