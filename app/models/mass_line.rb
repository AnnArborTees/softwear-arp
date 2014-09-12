class MassLine < ActiveRecord::Base
  after_initialize :assign_static_values

  before_validation :set_ink_volume
  validate :prefix, :no_prefix_conflict

  validates :prefix, :file_location_prefix, :machine_mode, :platen, :resolution, :ink, :ink_volume,
            :highlight3, :mask3, :highlightp, :maskp, :tolerance,
            :choke_width, :width, :height, :from_top, :from_center,
            presence: true


  private

  def no_prefix_conflict
    MassLine.all.each do |mass_line|
      if (mass_line.prefix.include? self.prefix or self.prefix.include? mass_line.prefix) and self.id != mass_line.id
        errors.add(:prefix, "There's a sku conflict with the mass line #{mass_line.prefix}")
      end
    end
  end

  def set_ink_volume
    if self.ink == 'C'
      self.ink_volume = 10
    else
      self.ink_volume = 0
    end
  end


  def assign_static_values
    self.machine_mode = 'GT-381'
    self.print_with_black_ink = true
    self.resolution = 600
    self.tolerance = 30
    self.choke_width = 3
    self.white_color_pause = false
    self.unidirectional = false
    self.multiple_pass = false
  end

end