
def sqlite_db_action(action, dump_version_number = nil)
  db_path = File.join(Rails.root, 'db', "#{Rails.env.downcase}.sqlite3")
  backup_path = File.join(Rails.root, 'db', 'backups').to_s
  schema_name = "#{Rails.env}"
  suffices = ['', '-journal', '-wal', '-shm']

  fn = if dump_version_number == nil || dump_version_number == ''
      File.join(backup_path, "#{schema_name}.sqlite3")
    else
      File.join(backup_path, "#{schema_name}.#{dump_version_number}.sqlite3")
    end
  puts sprintf("#{action} %-s -----------------------------", schema_name)
  begin
    if action == 'backup'
      suffices.each do |suf|
        puts "Backing up SQLite database to #{fn}#{suf}"
        exec "cp -f #{db_path}#{suf} #{fn}"
      end
    elsif action == 'restore'
      suffices.each do |suf|
        puts "Restoring SQLite database from #{fn}#{suf}"
        puts "  to #{db_path}#{suf}"
        if File.exist?(fn + suf)
          exec "rm -f #{db_path}#{suf}"
          exec "cp -f #{fn}#{suf} #{db_path}#{suf}"
        else
          puts "** File not found: #{fn}#{suf}"
        end
      end
    end
  rescue Exception => cmd_e
    puts "** #{cmd_e.message}"
  end
end

namespace :db do
  desc "Backup SQLite database"
  task :backup, [:dump_version_number] => [:environment] do |t, args|
    puts "args: #{args.class.superclass}"
    sqlite_db_action('backup', args[:dump_version_number] )
  end

  desc "Restore SQLite database"
  task :restore, [:dump_version_number] => [:environment] do |t, args|
    sqlite_db_action('restore', args[:dump_version_number] )
  end
end