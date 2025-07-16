# @return [Array] of model class => their associations to dump orderly
def seeds_order
  [
    Card => [:card_tiles, :card_abilities],
    Board => [:board_tiles]
  ]
end

def output_io
  @output_io ||= StringIO.new
end

namespace :seeds do
  # bin/rake seeds:dump_orderly >> db/seeds.rb 
  desc "Create seeds data that populates records with needed dependent associations"
  task dump_orderly: :environment do
    # puts "Creating seeds data..."
    io = output_io
    seeds_order.each do |group|
      group.each do|model_class, associations| # Board => [:board_tiles]
        root_record_name = model_class.name.underscore
        model_class.all.each do |m|
          io << "#{root_record_name} = #{model_class}.create!(#{m.attributes.except('id', 'updated_at', 'created_at').inspect})\n"
          associations.each do |assoc_name|
            if assoc_name.is_a?(Symbol)
              # puts "| #{model_class} (#{m.id}) => #{assoc_name} [#{m.send(assoc_name).count}]"
              m.send(assoc_name).each do |a|
                io << "  a = #{root_record_name}.#{assoc_name}.create!(#{a.attributes.except( *[model_class.reflect_on_association(assoc_name).foreign_key, 'id', 'updated_at', 'created_at'] ).inspect})\n"
              end
            elsif assoc_name.is_a?(Hash) #  { :game_users => [:game], :game => [:board] }
              # puts "| #{model_class} (#{m.id}) => #{assoc_name}"
              assoc_name.each_pair do| sub_assoc_name, sub_assoc_list |
                # puts "  | #{sub_assoc_name} => #{sub_assoc_list} [#{m.send(sub_assoc_name).count}]"
                m.send(sub_assoc_name).each do |sub_assoc|
                  except_alist = [model_class.reflect_on_association(sub_assoc_name).foreign_key, 'id', 'updated_at', 'created_at']
                  io << "  b = #{root_record_name}.#{sub_assoc_name}.create!(#{sub_assoc.attributes.except(*except_alist).inspect})\n"

                  # more associations
                  sub_assoc_list.each do |third_assoc_name|
                    third_level_assoc = sub_assoc.send(third_assoc_name)
                    except_alist = [sub_assoc.class.reflect_on_association(third_assoc_name).foreign_key, 'id', 'updated_at', 'created_at']

                    # puts "    | #{sub_assoc_name} => #{third_assoc_name}"
                    third_level_assoc.each do |assoc_item|
                      io << "  b.#{third_assoc_name}.create!(#{assoc_item.attributes.except(*except_alist).inspect})\n"
                    end
                  end
                  
                end # sub_assoc.each
              end
            end
          end
        end # each m
      end # group.each
    end # seed_order.each
    puts io.string
  end
end