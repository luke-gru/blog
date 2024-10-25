if Rails.env.production?
  if defined?(RubyVM::YJIT) && RubyVM::YJIT.respond_to?(:enable) && ENV["RUBY_NO_YJIT"].nil?
    RubyVM::YJIT.enable
    $stdout.puts "YJIT enabled"
  else
    $stdout.puts "YJIT is not enabled"
  end
end
