require 'bundler/setup'
require 'aws-sdk'
require 'time'
require 'optparse'

caller_reference = Time.now.utc.iso8601
options = {}

if !ENV['AWS_ACCESS_KEY_ID'] || !ENV['AWS_SECRET_ACCESS_KEY'] || !ENV['AWS_REGION']
  STDERR.puts("Please check environment variables")
  STDERR.puts("AWS_ACCESS_KEY_ID: #{ENV['AWS_ACCESS_KEY_ID']}")
  STDERR.puts("AWS_SECRET_ACCESS_KEY: #{ENV['AWS_SECRET_ACCESS_KEY']}")
  STDERR.puts("AWS_REGION: #{ENV['AWS_REGION']}")
  exit(false)
end

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: Invalidation.rb [options]"
  opts.on('-d', '--distribution ID', "Distribution ID") do |v|
    options[:distribution] = "#{v}"
  end
  opts.on('-p', '--path PATH', "Path to invalidate, e.g. /path/assets/*") do |v|
    options[:path] = "#{v}"
  end
  opts.on('-h', '--help', 'Display this help') do
    puts opts
    exit
  end
end

# http://stackoverflow.com/a/2149183
begin
  optparse.parse!
  mandatory = [:distribution, :path]
  missing = mandatory.select { |param| options[param].nil? }
  unless missing.empty?
    raise OptionParser::MissingArgument.new(missing.join(', '))
  end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts $!.to_s
  puts optparse
  exit
end

cloudfront = Aws::CloudFront::Client.new()
resp = cloudfront.create_invalidation({
    distribution_id: options[:distribution],
    invalidation_batch: {
        paths: {
            quantity: 1,
            items: [options[:path]],
        },
        caller_reference: caller_reference,
    },
})

puts "Created invalidation: #{resp.invalidation.id}"