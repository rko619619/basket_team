require 'tempfile'
require 'prawn'
require 'prawn/table'
require 'mini_magick'

class PdfGenerator
  def initialize(basketball_team, tournament)
    @basketball_team = basketball_team
    @tournament = tournament
    @players = @basketball_team.players.order(:jersey_number)
    @coaches = @basketball_team.coaches
    @resized_files = []
  end

  def generate_pdf
    Prawn::Document.generate("simple_test.pdf", page_size: 'A4', margin: [10, 10, 10, 10]) do |pdf|
      pdf.font_families.update("Times_New_Roman" => {
        normal: "#{Rails.root}/app/assets/fonts/Times_New_Roman.ttf",
        bold: "#{Rails.root}/app/assets/fonts/Times_New_Roman_Bold.ttf",
        italic: "#{Rails.root}/app/assets/fonts/Times_New_Roman_Italic.ttf",
        bold_italic: "#{Rails.root}/app/assets/fonts/Times_New_Roman_Bold_Italic.ttf"
      })
      pdf.font "Times_New_Roman"

      pdf.repeat(:all) do
        pdf.bounding_box([pdf.bounds.left + 10, pdf.bounds.top - 10], width: 80, height: 80) do
          pdf.image Rails.root.join('app/assets/images/pdf_logo.png'), width: 60, height: 60, position: :left
        end
        pdf.bounding_box([pdf.bounds.left + 80, pdf.bounds.top - 30], width: pdf.bounds.width - 150) do
          pdf.text "#{@tournament.name}", size: 15, style: :bold, align: :center, inline_format: true
        end
        pdf.bounding_box([pdf.bounds.right - 80, pdf.bounds.top - 10], width: 80) do
          pdf.image Rails.root.join('app/assets/images/betera_logo.png'), width: 60, height: 60, position: :right
        end
      end

      pdf.bounding_box([pdf.bounds.left + 80, pdf.bounds.top - 80], width: pdf.bounds.width - 150, height: 85) do
        pdf.text "Утвержденный список лицензий команды", size: 20, align: :center, inline_format: true
      end
      pdf.bounding_box([pdf.bounds.left + 80, pdf.bounds.top - 105], width: pdf.bounds.width - 150, height: 85) do
        pdf.text "«#{@basketball_team.name}»", size: 20, style: :bold, align: :center, inline_format: true
      end
      pdf.bounding_box([pdf.bounds.left + 80, pdf.bounds.top - 130], width: pdf.bounds.width - 150, height: 85) do
        pdf.text "(#{@basketball_team.description})", size: 18, align: :center, style: :bold, inline_format: true unless @basketball_team.description.nil?
      end

      pdf.bounding_box([15, pdf.bounds.top - 155], width: pdf.bounds.width - 100, height: 30) do
        pdf.text "ИГРОКИ:", size: 16, style: :bold, align: :left, inline_format: true
      end

      def resize_image(image_path, width, height)
        image = MiniMagick::Image.open(image_path)
        image.resize "#{width}x#{height}!" # Resize without preserving aspect ratio

        # Create a temporary file in the system's default temp directory
        temp_file = Tempfile.new(['resized_image', '.png'], Rails.root.join('tmp'), binmode: true)
        image.write(temp_file.path)
        temp_file.rewind
        @resized_files << temp_file
        temp_file.path
      end

      player_data = @basketball_team.players.sort_by(&:jersey_number).each_with_index.map do |player, index|
        player_photo_path = if player.photo.attached?
                              file = Tempfile.new(['player_photo', '.png'], Rails.root.join('tmp'), binmode: true)
                              file.write(player.photo.download)
                              file.rewind
                              resize_image(file.path, 80, 60)
                            else
                              nil
                            end

        player_citizenship_photo_path = if player.citizenship_photo.attached?
                                          file = Tempfile.new(['citizenship_photo', '.png'], Rails.root.join('tmp'), binmode: true)
                                          file.write(player.citizenship_photo.download)
                                          file.rewind
                                          resize_image(file.path, 90, 60)
                                        else
                                          nil
                                        end

        player_photo_image = player_photo_path ? { image: player_photo_path, position: :center } : "No Photo"
        player_citizenship_photo_image = player_citizenship_photo_path ? { image: player_citizenship_photo_path, position: :center } : "No Citizenship Photo"

        [
          index + 1,
          player_photo_image,
          player.last_name.upcase,
          player.first_name.upcase,
          player.birthdate.strftime("%d.%m.%Y"),
          player.license_number,
          player_citizenship_photo_image,
          player.jersey_number.upcase,
        ]
      end

      pdf.bounding_box([5, pdf.cursor + 100], width: pdf.bounds.width - 5) do
        pdf.move_down 90
        pdf.table(
          [['№', 'Фото', 'Фамилия', 'Имя', 'Дата рождения', '№ лицензии', 'Баскетбольное гражданство', 'Игровой номер']] + player_data,
          header: true,
          cell_style: { borders: [:left, :right, :top, :bottom],
                        border_width: 0.8,
                        align: :center,
                        valign: :center,
                        overflow: :shrink_to_fit,
                        size: 12,
                        padding: [0, 0, 0, 0]
          },
          column_widths: [20, 80, 90, 80, 80, 80, 90, 50]
        ) do |table|
          table.position = :center

          table.row(0).each_with_index do |cell, i|
            cell.font_style = :bold
            cell.align = :center
            cell.padding = [5, 0, 5, 0]
            cell.size = 11.5
          end

          # Применяем цвет для каждой строки
          table.rows(1..8).each_with_index do |row, i|
            player = @basketball_team.players.sort_by(&:jersey_number)[i]

            next unless player

            row_color = case player.color
                        when 'green'
                          'c0ff0c'
                        when 'blue'
                          '0000ff'
                        when 'red'
                          'ff0000'
                        when 'yellow'
                          'ffff00'
                        else
                          'ffffff'
                        end
            table.row(i+1).each do |cell|
              cell.background_color = row_color
            end

            table.columns(7).each do |cell|
              cell.font_style = :bold
            end
          end
        end
      end

      pdf.bounding_box([5, pdf.cursor - 20], width: pdf.bounds.width - 5) do
        data = [
          [{ content: '', background_color: 'ffff00' }, "- игроки с баскетбольным гражданством Российской Федерации"],
          [{ content: '', background_color: 'ff0000' }, "- игроки с иностранным баскетбольным гражданством"],
          [{ content: '', background_color: '00ff00' }, "- «молодой» игрок"]
        ]

        pdf.table(data, cell_style: { borders: [:left, :right, :top, :bottom], padding: [5, 5, 5, 5], size: 12, align: :left }, column_widths: [15, 400]) do |table|
          # Настраиваем цвет фона для первой колонки
          table.cells.column(0).each_with_index do |cell, i|
            cell.background_color = data[i][0][:background_color]
          end

          # Настройка шрифта и выравнивания текста для второй колонки
          table.cells.column(1).size = 14
          table.cells.column(1).align = :left
          table.cells.column(1).valign = :center

          # Настройка границ таблицы
          table.cells.borders = [:left, :right, :top, :bottom]
          table.cells.border_width = 0.6
        end
      end

      # Ensure all Tempfiles are closed and unlinked after PDF generation
      @resized_files.each(&:close!)
    end
  end
end
