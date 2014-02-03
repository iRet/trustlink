require 'fileutils'
require 'net/http'
require 'php_serialize'

module Trustlink
  class TlClient

    VERSION                = 'T0.0.1'
    DEBUG                  = false
    TEST_COUNT             = 4
    TEMPLATE               = 'template'
    USE_SSL                = false
    SERVER                 = 'db.trustlink.ru'
    CACHE_LIFETIME         = 3600
    CACHE_RELOADTIME       = 300

    class << self; attr_accessor :app_folder, :data_folder, :data, :charset, :host, :force_show_code, :multi_site, :is_static, :tl_user, :verbose, :test end

    attr_accessor :links, :links_page, :request_uri, :request, :error, :file_change_date, :file_size, :links_delimiter, :links_count, :isrobot, :skip_load_links

    def initialize user, request, options = {}
      @app_folder        = Rails.root
      @data_folder       = 'public'
      @data              = ''
      @charset           = 'UTF-8'
      @host              = ''
      @force_show_code   = false
      @multi_site        = false
      @is_static         = false
      @tl_user           = ''
      @verbose           = false
      @test              = false
      self.isrobot = false
      host = nil
      self.request=request
      @tl_user=user
      
      raise_error("User is not defined")         && return if @tl_user.blank?
      raise_error("Request env is not provided") && return if @request.blank?

      unless options.is_a?(Hash)
        host = options
        options = {}
      end

      host ||= options[:host]

      @host = host.present? ? host : (self.request.host rescue nil)
      @host = @host.gsub(/^https?:\/\//i, '').gsub(/^www\./i, '').downcase if @host.present?

      @is_static = options[:is_static].present?

      self.request_uri = options[:request_uri].present? ? options[:request_uri] : (self.request.original_url rescue nil)
      self.request_uri = self.request_uri.gsub(/\?.*$/, '').gsub(/\/+/, '/') if @is_static && self.request_uri.present?


      @app_folder = options[:app_folder] if options[:app_folder].present?
      @data_folder = options[:data_folder] if options[:data_folder].present?
      @multi_site = options[:multi_site].present?
      @verbose = options[:verbose].present? || (self.links['__trustlink_debug__'].present? rescue false)
      @charset = options[:charset] if options[:charset].present?
      self.skip_load_links = options[:skip_load_links] if options[:skip_load_links].present?
      @force_show_code = options[:force_show_code].present? || (self.links['__trustlink_debug__'].present? rescue false)

      if self.request.env['HTTP_TRUSTLINK'] == @tl_user
        @test = true
        self.isrobot = true
        @verbose = true
      end

      if self.request.parameters['trustlink_test'] == @tl_user
        @force_show_code=true
        @verbose = true
      end

      self.load_links unless self.skip_load_links
    end



    def load_links
      links_db_file = File.join(@app_folder, @data_folder, @tl_user, '/trustlink.links.db')
      links_db_file = File.join(@app_folder, @data_folder, @tl_user, '/trustlink.'+@host+'.links.db') if @multi_site

      if !File.exist?(links_db_file)
        begin
          if FileUtils.touch(links_db_file)
            File.utime(Time.now, Time.now - CACHE_LIFETIME,links_db_file)
            File.chmod(0666, links_db_file);
          else
            return self.raise_error("There is no file "+links_db_file+". Fail to create. Set mode to 777 on the folder.")
          end
        rescue Errno::ENOENT
          return self.raise_error("Can't create #{links_db_file} file. Check if #{@user} folder exist in #{@data_folder}.")
        end
      end

      if !File.writable?(links_db_file)
        self.raise_error("There is no permissions to write: "+links_db_file+"! Set mode to 777 on the folder.")
      end


      if File.mtime(links_db_file) < (Time.now-CACHE_LIFETIME) || (File.mtime(links_db_file) < (Time.now-CACHE_RELOADTIME) && (File.size(links_db_file) == 0))
        FileUtils.touch(links_db_file)

        path = '/'+@tl_user+'/'+@host.downcase+'/'+@charset.upcase

        if links = self.fetch_remote_file(SERVER, path)
          if links[0,12] == 'FATAL ERROR:'
            self.raise_error(links)
          else
            if !(@data = PHP.unserialize(links))
              self.links = {}
              self.raise_error("Cann't unserialize data from file.")
            end
            self.write(links_db_file, @data)
          end
        end
      end

      @data = self.read(links_db_file) if @data.blank?
      self.links = @data

      if self.links.blank?
        self.links = {}
        self.raise_error("Empty file.")
      end

      self.file_change_date = File.mtime(links_db_file)
      self.file_size = self.links.size
      self.links_page = []

      if @test
        TEST_COUNT.times do
          self.links_page << self.links['__test_tl_link__']
        end
      else
        self.links_page = self.links[self.request_uri]
        self.links_page = [] if self.links_page.blank?
      end

      self.links_count = self.links_page.size
    end

    def build_links n = nil

      return self.error if has_errors?

      total_page_links = self.links_page.size

      n = total_page_links if n.to_i<=0 || n.to_i > total_page_links

      res_links = self.links_page[0,n.to_i]

      result = ''

      if self.links['__trustlink_start__'].present? && ((self.links['__trustlink_robots__'] || []).include?(self.request.remote_addr) || @force_show_code)
        result += self.links['__trustlink_start__']
      end

      begin
        tpl_filename = File.join(@app_folder, @data_folder, @tl_user, TEMPLATE+'.tpl.html')
        tpl = read_raw(tpl_filename)
      rescue Errno::ENOENT
        raise_error("Template file not found")
        return self.error
      end

      block = ''
      if !tpl=~/\<\{block\}\>.+\<\{\/block\}\>/
        raise_error("Wrong template format: no <{block}><{/block}> tags")
      else
        tpl.sub!(/\<\{block\}\>(.+)\<\{\/block\}\>/im){block = $1; '%s'}
        raise_error("Wrong template format: no <{head_block}> tag.") if !block.include?('<{head_block}>')
        raise_error("Wrong template format: no <{/head_block}> tag.") if !block.include?('<{/head_block}>')
        raise_error("Wrong template format: no <{link}> tag.") if !block.include?('<{link}>')
        raise_error("Wrong template format: no <{text}> tag.") if !block.include?('<{text}>')
        raise_error("Wrong template format: no <{host}> tag.") if !block.include?('<{host}>')
      end

      links_block = ''

      res_links.each do |link|
        raise_error("format of link must be an array('anchor'=>anchor,'url'=>url,'text'=>text") if link.blank? || link['text'].blank? || link['url'].blank?
        parsed_host=extract_host(link['url'])
        if parsed_host.blank?
          raise_error("wrong format of url: "+link['url'])
        else
          level=parsed_host.split('.').size
          raise_error("wrong host: #{parsed_host} in url #{link['url']}") if level<2
        end
        unless has_errors?
          host=parsed_host.sub('www.','').downcase
          tmp_block = block.sub("<{host}>", host)
          if link['anchor'].blank?
            tmp_block.sub!(/\<\{head_block\}\>(.+)\<\{\/head_block\}\>/is, "")
          else
            href = link['punicode_url'].blank? ? link['url'] : link['punicode_url']
            tmp_block.sub!("<{link}>", '<a href="'+href+'">'+link['anchor']+'</a>')
            tmp_block.sub!("<{head_block}>", '')
            tmp_block.sub!("<{/head_block}>", '')
          end
          tmp_block.sub!("<{text}>", link['text'])
          links_block << tmp_block
        else
          result += self.error 
        end
      end

      if (self.links['__trustlink_robots__'] || []).include?(self.request.remote_addr) || @verbose

        result += self.error.to_s

        result += '<!--REQUEST_URI='+self.request.original_url+"-->\n"
        result += "\n<!--\n"
        result += 'L '+VERSION+"\n"
        result += 'REMOTE_ADDR='+self.request.remote_addr+"\n"
        result += 'request_uri='+self.request_uri+"\n"
        result += 'charset='+@charset+"\n"
        result += 'is_static='+@is_static.to_s+"\n"
        result += 'multi_site='+@multi_site.to_s+"\n"
        result += 'file change date='+self.file_change_date.to_s+"\n"
        result += 'lc_file_size='+self.file_size.to_s+"\n"
        result += 'lc_links_count='+self.links_count.to_s+"\n"
        result += 'left_links_count='+self.links_page.size.to_s+"\n"
        result += 'n='+n.to_s+"\n"
        result += '-->'
      end

      if res_links.present? && res_links.size>0
        tpl = sprintf(tpl, links_block)
        result += tpl
      end

      if self.links['__trustlink_end__'].present? && ((self.links['__trustlink_robots__'] || []).include?(self.request.remote_addr) || @force_show_code)
        result += self.links['__trustlink_end__']
      end

      result = '<noindex>'+result+'</noindex>' if (@test && !self.isrobot)

      result

    end


    def fetch_remote_file host, path
      user_agent = 'Trustlink Client RoR ' + VERSION
      resp=Net::HTTP.start(host) { |http|
        http.get(path)
      }
      if resp.body
        resp.body.force_encoding('UTF-8')
      else
        self.raise_error("Can't connect to server: "+host+path)
      end
    end


    def read filename
      Marshal.load(read_raw filename)
    end

    def read_raw filename
      open(filename, "rb") { |file|
        file.read
      }
    end

    def write filename, data
      write_raw(filename, Marshal.dump(data))
    end

    def write_raw filename, data
      open(filename, "wb") { |file|
        file.write(data)
      }
    end

    def raise_error msg
      self.error ||= ''
      self.error << "<!--ERROR: #{msg}-->\n"
    end

    def has_errors?
      self.error.present?
    end

    def extract_host(url)
      if url =~ %r{^(?:https?://)?(?:www.)?([^/]+)(?:/|$)}
        $1
      else
        ""
      end
    end
  end
end
