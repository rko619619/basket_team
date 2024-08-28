require 'tempfile'
require 'prawn'
require 'prawn/table'
require 'mini_magick'
require 'image_processing/mini_magick'
require 'image_processing/vips'
require 'rmagick'

class PdfGenerator
  def initialize(basketball_team, tournament)
    @basketball_team = basketball_team
    @tournament = tournament
    @players = @basketball_team.players.order(:jersey_number)
    @coaches = @basketball_team.coaches
    @resized_files = []
  end

  def generate_pdf
    Prawn::Document.generate("#{@basketball_team.name}.pdf", page_size: 'A4', margin: [10, 10, 10, 10]) do |pdf|
      set_font_families(pdf)
      header_for_page(pdf)
      title_for_page(pdf)
      players_table(pdf)
      color_table(pdf)
      sign(pdf)
      coaches_table(pdf)
      sign(pdf)
    end
  ensure
    @resized_files.each(&:close!)
  end

  private

  def set_font_families(pdf)
    pdf.font_families.update("Times_New_Roman" => {
      normal: "#{Rails.root}/app/assets/fonts/Times_New_Roman.ttf",
      bold: "#{Rails.root}/app/assets/fonts/Times_New_Roman_Bold.ttf",
      italic: "#{Rails.root}/app/assets/fonts/Times_New_Roman_Italic.ttf",
      bold_italic: "#{Rails.root}/app/assets/fonts/Times_New_Roman_Bold_Italic.ttf"
    })
    pdf.font "Times_New_Roman"
  end

  def header_for_page(pdf)
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
  end

  def title_for_page(pdf)
    background_color = 'D3D3D3' # Темный светло-серый цвет

    if @basketball_team.description.present?
      color_background_box_height = 23
    else
      color_background_box_height = 45
    end
    # Первый текстовый блок
    pdf.bounding_box([pdf.bounds.left + 80, pdf.bounds.top - 76], width: pdf.bounds.width - 150, height: 85) do
      # Рисуем фон
      pdf.fill_color background_color
      pdf.fill_rectangle([pdf.bounds.left, pdf.bounds.top + 2], pdf.bounds.width , pdf.bounds.height - color_background_box_height)

      # Возвращаем цвет текста
      pdf.fill_color '000000'
      pdf.text "Утвержденный список лицензий команды", size: 20, align: :center, inline_format: true
    end

    # Второй текстовый блок
    pdf.bounding_box([pdf.bounds.left + 80, pdf.bounds.top - 96], width: pdf.bounds.width - 150, height: 85) do
      pdf.fill_color '000000'
      pdf.text "«#{@basketball_team.name}»", size: 20, style: :bold, align: :center, inline_format: true
    end

    if @basketball_team.description.present?
      # Третий текстовый блок
      pdf.bounding_box([pdf.bounds.left + 80, pdf.bounds.top - 116], width: pdf.bounds.width - 150, height: 85) do

        pdf.fill_color '000000'
        pdf.text "(#{@basketball_team.description})", size: 18, align: :center, style: :bold, inline_format: true unless @basketball_team.description.nil?
      end
    end
  end

  def resize_image(image_content, width, height)
    tempfile = Tempfile.new(['temp_image', '.png'], Rails.root.join('tmp'), binmode: true)
    tempfile.write(image_content)
    tempfile.rewind

    image = MiniMagick::Image.open(tempfile.path)

    # Изменяем размер изображения и обрезаем до нужного размера
    image.resize "#{width}x#{height}!"

    # Оптимизация изображения (уменьшение качества для JPEG)
    image.format "png"
    image.quality "100" # Это аналогично max_quality для JPEG

    # Сохраняем изображение во временный файл
    temp_file = Tempfile.new(['resized_image', '.jpg'], Rails.root.join('tmp'), binmode: true)
    image.write(temp_file.path)

    # Перематываем файл на начало
    temp_file.rewind
    @resized_files << temp_file
    temp_file.path
  end

  def players_table(pdf)
    if @basketball_team.description.present?
      pdf.bounding_box([5, pdf.bounds.top - 145], width: pdf.bounds.width - 100, height: 30) do
        pdf.text "ИГРОКИ:", size: 16, style: :bold, align: :left, inline_format: true
      end
    else
      pdf.bounding_box([5, pdf.bounds.top - 125], width: pdf.bounds.width - 100, height: 30) do
        pdf.text "ИГРОКИ:", size: 16, style: :bold, align: :left, inline_format: true
      end
    end

    player_data = @basketball_team.players.sort_by(&:jersey_number).each_with_index.map do |player, index|
      player_photo_path = if player.photo.attached?
                            resize_image(player.photo.download, 60, 79)  # Use download.path if photo is ActiveStorage
                          else
                            nil
                          end

      player_citizenship_photo_path = if player.citizenship_photo.attached?
                                        resize_image(player.citizenship_photo.download, 80, 60)  # Use download.path if photo is ActiveStorage
                                      else
                                        nil
                                      end

      player_photo_image = player_photo_path ? { image: player_photo_path, position: :center } : "Нет фото"
      player_citizenship_photo_image = player_citizenship_photo_path ? { image: player_citizenship_photo_path, position: :center } : "Нет фото"

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
        cell_style: { height: 80,
          borders: [:left, :right, :top, :bottom],
                      border_width: 1,
                      align: :center,
                      valign: :center,
                      overflow: :shrink_to_fit,
                      size: 12,
                      padding: [0, 0, 0, 0]
        },
        column_widths: [20, 60, 100, 100, 80, 75, 90, 45]
      ) do |table|
        table.position = :center

        table.row(0).each_with_index do |cell, i|
          cell.font_style = :bold
          cell.align = :center
          cell.padding = [5, 0, 5, 0]
          cell.size = 11.5
        end

        table.rows(1..-1).each_with_index do |row, i|
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

          table.columns(1).each do |cell|
            cell.padding = [0.5, 0, 0, 0]
          end

          table.columns(7).each do |cell|
            cell.font_style = :bold
          end

          table.columns(6).each do |cell|
            cell.padding = [10, 5, 10, 5]
          end

          table.cells.columns(7).rows(1..-1).each do |cell|
            cell.size = 20
          end
        end
      end
    end
  end

  def table_for_color(pdf, padding)
    pdf.bounding_box([5, pdf.cursor - padding], width: pdf.bounds.width - 5) do
      data = [
        [{ content: '', background_color: 'ffff00' }, "- игроки с баскетбольным гражданством Российской Федерации"],
        [{ content: '', background_color: 'ff0000' }, "- игроки с иностранным баскетбольным гражданством"],
        [{ content: '', background_color: '00ff00' }, "- «молодой» игрок"]
      ]

      pdf.table(data, cell_style: { size: 12, align: :left }, column_widths: [60, 400]) do |table|
        # Настройка первого столбца (с цветными квадратами)
        table.cells.column(0).each_with_index do |cell, i|
          cell.background_color = data[i][0][:background_color]
          cell.borders = [:left, :right, :top, :bottom] # Включаем рамки
          cell.border_width = 0.6
        end

        # Настройка второго столбца (с текстом)
        table.cells.column(1).each do |cell|
          cell.borders = []
          cell.size = 14
          cell.align = :left
        end
      end
    end
  end

  def color_table(pdf)
    if pdf.cursor < 150
      pdf.start_new_page
      table_for_color(pdf, 90)
    else
      table_for_color(pdf, 20)
    end
  end

  def sign(pdf)
    if pdf.cursor < 90
      pdf.start_new_page
      pdf.bounding_box([pdf.bounds.left + 185, pdf.cursor - 90], width: 180, height: 90) do
        pdf.image Rails.root.join('app/assets/images/sign.png'), width: 180, height: 90, position: :left
      end
    else
      pdf.bounding_box([pdf.bounds.left + 185, pdf.cursor - 20], width: 180, height: 90) do
        pdf.image Rails.root.join('app/assets/images/sign.png'), width: 180, height: 90, position: :left
      end
    end
  end

  def coaches_table(pdf)
    pdf.start_new_page

    title_for_page(pdf)

    pdf.bounding_box([5, pdf.bounds.top - 150], width: pdf.bounds.width - 100, height: 30) do
      pdf.text "ТРЕНЕРСКО-АДМИНИСТРАТИВНЫЙ ПЕРСОНАЛ:", size: 16, style: :bold, align: :left, inline_format: true
    end

    coaches_data = @basketball_team.coaches.each_with_index.map do |coache, index|
      [
        index + 1,
        coache.last_name.upcase,
        coache.first_name.upcase,
        coache.date_of_birth.strftime("%d.%m.%Y"),
        coache.license_number,
        coache.position
      ]
    end

    pdf.bounding_box([5, pdf.bounds.top - 170], width: pdf.bounds.width - 5) do
      pdf.table(
        [['№', 'Фамилия', 'Имя', 'Дата рождения', '№ лицензии', 'Должность']] + coaches_data,
        header: true,
        cell_style: { borders: [:left, :right, :top, :bottom],
                      border_width: 0.8,
                      align: :center,
                      valign: :center,
                      overflow: :shrink_to_fit,
                      size: 12,
                      padding: [7, 0, 7, 0]
        },
        column_widths: [20, 110, 80, 70, 90, 200]
      ) do |table|
        table.position = :center
      end
    end
  end
end
