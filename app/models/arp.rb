class Arp < ActiveRecord::Base

  PLATENS = %w(14x16 10x12 7x8 16x18)
  INKS = %w(cw C W)

  belongs_to :spreadsheet

  after_initialize :assign_static_values

  validates :sku, uniqueness: {scope: :platen}, presence: true
  validates :platen, presence: true
  validates :platen, inclusion: { in: PLATENS }

  def find_mockbot_idea_for_arp
    idea = MockBot::Idea.find(self.sku)
    idea.respond_to?('sku') ? idea : nil
  end

  def populate_info_from_mockbot(idea = nil)
    idea = MockBot::Idea.find(self.sku) unless !idea.nil?
    if idea.respond_to?('sku')
      self.file_location = default_file_location
      if idea.base?
        self.highlight3 = 7
        self.mask3 = 3
        self.highlightp = 1
        self.maskp = 3
        self.ink = 'cw'
        self.ink_volume = 0
      else
        self.highlight3 = 0
        self.mask3 = 0
        self.highlightp = 0
        self.maskp = 0
        self.ink = 'C'
        self.ink_volume = 10
        self.print_with_black_ink = 1
        self.cmy_gray = 0
      end

      idea.artworks.each do |artwork|
        if artwork.dimensions == self.platen
          self.from_top = in_inches(artwork.from_top, artwork.dpi)
          self.from_center = in_inches(artwork.from_center, artwork.dpi)
          self.width = in_inches(artwork.width, artwork.dpi)
          self.height = in_inches(artwork.height, artwork.dpi)
          self.transparency = !artwork.is_transparent
          self.print_with_black_ink = true
          self.cmy_gray = false
          if artwork.is_transparent
            self.transparency_red = 0
            self.transparency_blue = 0
            self.transparency_green = 0
          else
            rgb = artwork.background_color.gsub("#", '').scan(/../).map {|color| color.to_i(16)}
            self.transparency_red = rgb[0]
            self.transparency_blue = rgb[1]
            self.transparency_green = rgb[2]
            if artwork.background_color == '#000000'
              self.print_with_black_ink = false
              self.cmy_gray = true
            end
          end
        end
      end

    end
  end

  def find_mass_line_for_arp
    MassLine.all.each do |mass_line|
      if self.sku.starts_with? mass_line.prefix
        return mass_line
      end
    end
    nil
  end

  def populate_info_from_mass_line(mass_line = nil)
    mass_line = find_mass_line_for_arp unless !mass_line.nil?
    if !mass_line.nil?
      self.file_location = file_location_from_mass_line mass_line
      self.machine_mode = mass_line.machine_mode
      self.platen = mass_line.platen
      self.resolution = mass_line.resolution
      self.ink = mass_line.ink
      self.ink_volume = mass_line.ink_volume
      self.highlight3 = mass_line.highlight3
      self.mask3 = mass_line.mask3
      self.highlightp = mass_line.highlightp
      self.maskp = mass_line.maskp
      self.print_with_black_ink = mass_line.print_with_black_ink
      self.cmy_gray = mass_line.cmy_gray
      self.multiple_pass = mass_line.multiple_pass
      self.transparency = mass_line.transparency
      self.transparency_red = mass_line.transparency_red
      self.transparency_blue = mass_line.transparency_blue
      self.transparency_green = mass_line.transparency_green
      self.tolerance = mass_line.tolerance
      self.choke_width = mass_line.choke_width
      self.white_color_pause = mass_line.white_color_pause
      self.unidirectional = mass_line.unidirectional
      self.width = mass_line.width
      self.height = mass_line.height
      self.from_top = mass_line.from_top
      self.from_center = mass_line.from_center
    end
  end

  private

  def assign_static_values
    self.machine_mode = 'GT-381'
    self.resolution = 600
    self.tolerance = 30
    self.choke_width = 3
    self.white_color_pause = 0
    self.unidirectional = 0
    self.multiple_pass = 0
  end

  def default_file_location
    '\\\\AATC\\Retail\\ReadyToPublish\\' + self.sku.split('_')[0] + '\\' + self.sku.strip + '\\'+ self.sku.strip + self.platen.strip + '.png'
  end

  def file_location_from_mass_line(mass_line)
    location = mass_line.file_location_prefix
    if location[-1,1] != '\\'
      location = location + '\\'
    end
    "#{location}#{self.sku}#{self.platen}.png"
  end

  def in_inches(pixels, dpi)
    pixels = pixels.to_i
    dpi = dpi.to_i
    ((pixels * 1.0) / (dpi * 1.0)).round(1)
  end

end
