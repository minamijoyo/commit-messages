require 'octokit'

puts "Start initialization"
# Open file for results
File.open("commits.txt", "w") do |file|

  # GitHub API access token must be exported
  access_token = ENV['GITHUBAPI_ACCESS_TOKEN']
  raise "GITHUBAPI_ACCESS_TOKEN must be exported !!" if access_token.nil?

  # Octokit initialization
  client = Octokit::Client.new(:access_token => access_token)
  raise "Octokit initialization error" if client.nil?

  # Octokit setting
  client.auto_paginate = true

  # print login user
  puts "Login user: #{client.user.login}"

  # check the current rate limit before call API
  puts "Check rate limit: #{client.rate_limit}"
  sleep 60 unless client.rate_limit.remaining

  # search popular repositories
  puts "Search repositories on GitHub"
  search_results = client.search_repos('stars:>10000', :per_page => 100)
  repos = search_results.items.map(&:full_name)
  puts "Target repositories: #{repos}"

  # for each repository
  repos.each do |repo|
    # check the current rate limit before call API
    puts "Check rate limit: #{client.rate_limit}"
    sleep 60 unless client.rate_limit.remaining

    # get commits list on the repository
    puts "Get commit messages on github:#{repo}"
    commits = client.commits(repo, :per_page => 100)

    # for each commit
    commits.each do |commit|
      sha = commit[:sha]
      message = commit[:commit][:message]
      file.puts "#{repo}, #{sha}, #{message}"
    end
  end
end