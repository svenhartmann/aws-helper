require 'bundler/setup'
require 'aws-sdk'
require 'erubis'
require 'optparse'

if !ENV['AWS_ACCESS_KEY_ID'] || !ENV['AWS_SECRET_ACCESS_KEY'] || !ENV['AWS_REGION']
  STDERR.puts("Please check environment variables")
  STDERR.puts("AWS_ACCESS_KEY_ID: #{ENV['AWS_ACCESS_KEY_ID']}")
  STDERR.puts("AWS_SECRET_ACCESS_KEY: #{ENV['AWS_SECRET_ACCESS_KEY']}")
  STDERR.puts("AWS_REGION: #{ENV['AWS_REGION']}")
  exit(false)
end

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: Invalidation.rb [options]"
  opts.on('-t', '--template Template', "Output template") do |v|
    options[:template] = "#{v}"
  end
  opts.on('-h', '--help', 'Display this help') do
    puts opts
    exit
  end
end

# http://stackoverflow.com/a/2149183
begin
  optparse.parse!
  mandatory = [:template]
  missing = mandatory.select { |param| options[param].nil? }
  unless missing.empty?
    raise OptionParser::MissingArgument.new(missing.join(', '))
  end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts $!.to_s
  puts optparse
  exit
end

templateFile = File.read(options[:template])
template = Erubis::Eruby.new(templateFile)
client = Aws::OpsWorks::Client.new()

resp = client.describe_stacks({})

if resp.stacks.nil?
  STDERR.puts("No Stacks found")
end

stacks = {}
resp.stacks.each do |stack|
  instancesList = client.describe_instances({
       stack_id: stack.stack_id
  })
  stacks[stack.stack_id] = {:stack => stack, :instances => instancesList.instances}
end

puts template.result(:stacks => stacks)
