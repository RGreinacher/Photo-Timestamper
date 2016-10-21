require 'awesome_print'
require 'mini_exiftool'
require 'digest/md5'
require 'Date'

# change this folder paths
@source_path = '/absolute/path/to/a/folder/containing/images'
@target_path = '/absolute/path/to/output'

@meta_data_file_name = 'meta_data.dat'
@image_hashes = {}
@camera_hashes = []
@default_date = 'unknown_date'

# use ths hash to correct a camera's wrong datetime settings
# @date_time_correction = {
#   "4e2bbb4e3084125565d146aafdf3b6dd" => 81960,
#   "5b8422f371f5a9926093effd6b5e3080" => 82080,
#   "3950e76ad45beb6e9efcac86c9c1abcb" => 81960
# }
@date_time_correction = {}

def is_duplicate?(dir, item)
  file_path = "#{dir}/#{item}"
  md5_hash = Digest::MD5.hexdigest(File.read(file_path))

  if @image_hashes.include? md5_hash
    ap "photo '#{item}' is a duplicate of photo '#{@image_hashes[md5_hash]}'"
    return true
  end

  @image_hashes[md5_hash] = item
  false
end

def read_exif_data(file_path)
  exif_data = MiniExiftool.new file_path

  if exif_data
    exif_hash = exif_data.to_hash

    # estimate camera specific ID
    camera_specifica = extract_camera_specific_information exif_hash
    camera_specific_md5_hash = Digest::MD5.hexdigest camera_specifica
    camera_id = camera_hash_to_id camera_specific_md5_hash

    # find capture timestamp
    date_time = extract_date_time exif_hash
    formatted_creation_date = parse_date_time date_time, camera_specific_md5_hash

    return formatted_creation_date, camera_id
  end

  return @default_date, -1
end

def extract_date_time(exif_hash)
  creation_date = exif_hash['CreateDate'] if exif_hash['CreateDate']
  creation_date = exif_hash['DateTimeCreated'] if exif_hash['DateTimeCreated']
  creation_date = exif_hash['DateTimeOriginal'] if exif_hash['DateTimeOriginal']
  creation_date = exif_hash['SonyDateTime'] if exif_hash['SonyDateTime']
  creation_date.to_s
end

def parse_date_time(date_time_str, camera_hash)
  return @default_date if date_time_str.empty?
  date_time = DateTime.parse date_time_str

  # apply time correction for certain cameras
  if @date_time_correction.include? camera_hash
    ap 'TIME CORRECTION!'
    date_time +=  (@date_time_correction[camera_hash] / 86400.0)
  end

  date_time.strftime("%Y-%m-%d_%H-%M-%S")
end

def extract_camera_specific_information(exif_hash)
  camera_information = ''
  camera_information += exif_hash['Make'] if exif_hash['Make']
  camera_information += exif_hash['Model'] if exif_hash['Model']
  camera_information += exif_hash['ExifByteOrder'] if exif_hash['ExifByteOrder']
  camera_information += exif_hash['ExifVersion'].to_s if exif_hash['ExifVersion']
  camera_information += exif_hash['ResolutionUnit'] if exif_hash['ResolutionUnit']
  camera_information += exif_hash['Artist'] if exif_hash['Artist']
  camera_information += exif_hash['Copyright'] if exif_hash['Copyright']
  camera_information += exif_hash['SerialNumber'].to_s if exif_hash['SerialNumber']
  camera_information += exif_hash['LensInfo'] if exif_hash['LensInfo']
  camera_information += exif_hash['LensModel'] if exif_hash['LensModel']
  camera_information += exif_hash['YCbCrSubSampling'] if exif_hash['YCbCrSubSampling']
  camera_information
end

def camera_hash_to_id(camera_hash)
  return @camera_hashes.index camera_hash if @camera_hashes.include? camera_hash
  @camera_hashes.push camera_hash
  @camera_hashes.size - 1
end

def copy_and_rename(source_directory, item, timestamp, camera_id)
  target_name = "#{timestamp}_camera#{camera_id}_#{item}"
  FileUtils.cp("#{source_directory}/#{item}", "#{@target_path}/#{target_name}")
end

def load_meta_data
  byte_stream = File.read(@meta_data_file_name)
  meta_data = Marshal.load(byte_stream)
  @image_hashes = meta_data[0]
  @camera_hashes = meta_data[1]
rescue Errno::ENOENT
  @image_hashes = {}
  @camera_hashes = []
end

def save_meta_data
  meta_data = [@image_hashes, @camera_hashes]
  byte_stream = Marshal.dump(meta_data)
  open(@meta_data_file_name, 'wb') { |f| f.puts byte_stream }
end

def read_directory(dir)
  Dir.foreach(dir) do |item|
    next if item == '.' or item == '..' or item == '.DS_Store'

    absolute_item_path = "#{dir}/#{item}"
    if File.directory? absolute_item_path
      read_directory absolute_item_path
    else
      ap "processing photo '#{item}'..."

      next if is_duplicate? dir, item
      timestamp, camera_id = read_exif_data absolute_item_path
      copy_and_rename dir, item, timestamp, camera_id
      save_meta_data
    end
  end
end

load_meta_data
read_directory @source_path
ap @camera_hashes
