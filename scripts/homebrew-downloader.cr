require "file_utils"
require "http/client"
require "json"
require "log"

HOMEBREW_API_FORMULA_URL = "https://formulae.brew.sh/api/formula.json"

struct BrewFormula
  include JSON::Serializable

  alias BottleFile = {url: String, sha256: String}

  getter name : String
  getter aliases : Array(String)

  @versions : {stable: String}

  @bottle : {stable: {files: {arm64_monterey: BottleFile?, monterey: BottleFile?}}}

  def version
    @versions[:stable]
  end

  def arm64_monterey?
    @bottle[:stable][:files][:arm64_monterey]
  end
end

record DownloadEntry, name : String, version : String, url : String, sha256 : String

def ghcr_download(uri : URI, headers : HTTP::Headers, target_io : IO)
  # setup a new client for each entry as we need to follow redirects
  HTTP::Client.new(uri) do |client|
    client.get(uri.request_target, headers: headers) do |response|
      if response.success?
        IO.copy(response.body_io, target_io)
        return
      end

      if response.status.temporary_redirect? || response.status.permanent_redirect?
        redirect_uri = URI.parse(response.headers["Location"])
        ghcr_download(redirect_uri, headers, target_io)
      end
    end
  end
end

def main(argv = ARGV, log = Log)
  # directory where to extract everything
  unless target_dir = argv.shift?
    log.error { "Target directory is required" }
    exit 1
  end

  # ensure directory exists
  log.debug &.emit("Creating target directory", target_dir: target_dir)
  target_dir_lib = File.join(target_dir, "lib")
  target_dir_pkgconfig = File.join(target_dir_lib, "pkgconfig")
  Dir.mkdir_p(target_dir_pkgconfig, 0o755)

  packages = argv[0..-1].to_set
  if packages.empty?
    log.error { "At least one package (or alias) is required" }
    exit 1
  end

  download_entries = Array(DownloadEntry).new

  log.debug { "Fetching Homebrew API index" }
  HTTP::Client.get(HOMEBREW_API_FORMULA_URL) do |response|
    formulas = Array(BrewFormula).from_json(response.body_io)

    formulas.each do |formula|
      next unless formula.name.in?(packages) || (formula.aliases.any? &.in?(packages))

      log.debug &.emit("Formula found", name: formula.name, version: formula.version)

      # collect URLs
      if file = formula.arm64_monterey?
        download_entries << DownloadEntry.new(formula.name, formula.version, file[:url], file[:sha256])
      else
        log.warn &.emit("No ARM64 Monterey download found", name: formula.name, version: formula.version)
      end
    end
  end

  # GitHub registry requires empty 'Bearer' token
  ghcr_authorization = HTTP::Headers{"Authorization" => "Bearer QQ=="}

  download_entries.each do |entry|
    uri = URI.parse(entry.url)
    temp_io = File.tempfile("homebrew_", ".tar.gz")
    ghcr_download(uri, ghcr_authorization, temp_io)

    temp_io.flush
    log.debug &.emit("File downloaded", path: temp_io.path, size: temp_io.size)

    temp_dir = File.tempname
    Dir.mkdir_p(temp_dir, 0o755)

    log.debug &.emit("Extracting package", path: temp_io.path, target: temp_dir)
    status = Process.run("tar", {"-xf", temp_io.path, "-C", temp_dir, "--strip-components=2"})
    unless status.success?
      log.error &.emit("Unable to extract package", name: entry.name, version: entry.version, exit_status: status.exit_status)
      exit 1
    end

    Dir.glob(File.join(temp_dir, "**/*.a")).each do |source|
      FileUtils.cp(source, target_dir_lib)
    end

    Dir.glob(File.join(temp_dir, "**/*.pc")).each do |source|
      FileUtils.cp(source, target_dir_pkgconfig)
    end

    log.info &.emit("Extracted files (.a, .pc) from package", name: entry.name, version: entry.version)
  ensure
    log.debug &.emit("Cleanup after package", name: entry.name, version: entry.version)
    temp_io.delete if temp_io
    FileUtils.rm_rf(temp_dir) if temp_dir
  end
end

Log.setup_from_env

main(ARGV.dup, Log)
