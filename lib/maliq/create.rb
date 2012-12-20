class Maliq::Create
  def initialize(files, opts={})
    @opts = opts
    @csses = opts.delete(:css)
    @mdfiles = get_markdown_files(files)
  end

  def get_markdown_files(files)
    files.select { |f| f.match /\.(md|markdown)$/ }
        .tap { |res|
          if res.empty?
            abort "Must pass one or more markdown filenames to build xhtml output."
          end
        }
  end
  private :get_markdown_files

  def run!
    lastname = nil
    @mdfiles.each_with_index do |fname, fno|
      dirname = File.dirname(fname)
      if @opts[:seq] && lastname
        seq_name = Maliq::FileUtils.create_filename(lastname)
      end

      # Split a file at split markers to several chapters,
      # each of which has title a label.
      chapters = Maliq::FileUtils.split(fname)

      chapters.each do |title, text|
        #this change filenames with sequential names.
        if @opts[:seq] && !fno.zero?
          title = seq_name.tap { |s| seq_name = seq_name.next }
        end

        dest = title.basename_with(:xhtml)
        convert_and_save(text, File.join(dirname, dest))
        lastname = title
      end
    end
  end

  private
  def convert_and_save(md, dest)
    conv = Maliq::Converter.new(md, css:@csses)
    conv.set_meta(liquid:@opts[:liquid]) if @opts[:liquid]
    conv.save(dest)
  end
end