class Profile < ActiveRecord::Base

  belongs_to :user

  validates  :directories, presence: true
  # validates  :directories, uniqueness: true

  before_create :backup
  after_destroy :clean_contents

  def backup
    # system("sudo -S chmod -R 777 /home/angga/Videos/") if cannot access folder
    ff = self.exclusions.split(",").map{|x| "--exclude='#{x}'"}.join(" ")
    dir_name = "#{self.name.gsub(" ","_")}-#{Time.now.to_i}"
    # system("mkdir #{dir_name}")
    self.storage_directory = "public/#{dir_name}"
    self.directories.split(",").each do |directory|
        system("rsync -avz #{ff} #{directory} public/#{dir_name}")
    end
  end

  def clean_contents
    return system("rm -rf #{self.storage_directory}")
  end

  def restore
    self.directories.split(",").each do |directory|
      backup_base = directory.split("/").last
      source_dir = "#{self.storage_directory}/#{backup_base}"
      source_storage = File.directory?(source_dir) ? "#{source_dir}/*" : source_dir
      system("rsync -avz #{source_storage} #{directory}")
    end
  end

  def self.detail(directories)
    contents = []
    total_size = IO.popen("du -sh #{directories.split("/").join("/")}/").readlines.first
    directory = !directories.strip[-1].eql?("/") ? (directories.strip + "/*") : (directories.strip + "*")
    Dir.glob(directory).each do |file|
      unless File.directory? file
        detail_file = File.stat("#{file}")
        detail_file
        contents << {type: "file", name: file.split("/").last, size: detail_file.size, create_at: detail_file.ctime}
      else
        contents << {type: "directory", name: file.split("/").last, directory: file }
      end
    end
    return [total_size ,contents.sort_by{ |k,v| k[:type]}]
  end

  def self.delete_file(directory, file)
    current_directory = directory.split("/")
    file_path = current_directory << file
    system("rm -rf '#{file_path.join("/")}'")
  end
end
