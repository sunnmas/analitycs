class BaseUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  storage :file

  def check_file_size
    return unless @max_file_size
    return unless File.size?(current_path)&.> @max_file_size
    model.errors.add @attribute, I18n.t('errors.messages.max_size_error',
                                        max_size: @max_file_size.unmegabyte,
                                        filename: original_filename)
  end

  def check_resolution
    @img = ::MiniMagick::Image.open current_path
    if (@max_height&.< @img.height) || (@max_width&.< @img.width)
      model.errors.add @attribute, I18n.t('errors.messages.max_resolution', height: @max_height, width: @max_width)
    end
    if (@min_height&.> @img.height) || (@min_width&.> @img.width)
      model.errors.add @attribute, I18n.t('errors.messages.min_resolution', height: @min_height, width: @min_width)
    end
  end

  def quality(percentage)
    `mogrify -quality #{percentage} #{current_path}`
  end

  def filename
    if original_filename
      "#{model.class.name.downcase}.#{Digest::MD5.hexdigest(original_filename)[0..7]}.#{file.extension}"
    end
  end

  def store_dir
    return "test/images/db#{ENV['TEST_ENV_NUMBER']}/#{model.class.name.downcase}/#{model.id}" if Rails.env.test?
    "images/#{model.class.name.downcase}/#{model.id}"
  end

  CarrierWave::SanitizedFile.sanitize_regexp = /[^a-zA-Zа-яА-ЯёЁ0-9\.\-\+_]/u
end
