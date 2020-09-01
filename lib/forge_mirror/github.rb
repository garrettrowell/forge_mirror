require 'octokit'
require 'rugged'

module ForgeMirror
  class Github
    def self.check_repos(modules)
      @org = ForgeMirror.configuration.github[:organization]
      @work_dir = ForgeMirror.configuration.general[:work_dir]
      @internal_client = Octokit::Client.new(
        access_token: ForgeMirror.configuration.github[:access_token],
        api_endpoint: ForgeMirror.configuration.github[:internal_api_endpoint]
      )
      @external_client = Octokit::Client.new(
        proxy: ForgeMirror.configuration.general[:proxy]
      )

      modules.each do |m|
        repo_ext = Octokit::Repository.from_url(m[1][:url])

        # normalize slugs for both internal and external repos
        slug_ext = "#{repo_ext.owner}/#{repo_ext.name}"
        slug_int = "#{@org}/#{repo_ext.name}"

        # check if internal repository exists
        in_org = @internal_client.repository?(slug_int)
        msg = in_org ? " exists" : " doesn't exist"
        ForgeMirror.log.info(slug_int + msg)

        repo_info_ext = @external_client.repository(slug_ext)

        if in_org
          repo_info_int = @internal_client.repository(slug_int)
          tags_int = s_name(@internal_client.tags(slug_int)).sort
          tags_ext = s_name(@external_client.tags(slug_ext)).sort

          tags_missing_int = tags_ext - tags_int
          tags_match = tags_missing_int.empty?

          if tags_match
            ForgeMirror.log.info("#{slug_int} is currently up-to date with #{slug_ext}")
          else
            ForgeMirror.log.info("#{slug_int} is missing the following tags: #{tags_missing_int} tags")
            ForgeMirror::Git.create_mirror(repo_info_ext[:ssh_url], repo_info_int[:ssh_url], "#{@work_dir}/#{repo_ext.name}")
          end
        else
          ForgeMirror.log.info("#{slug_int} does not exist internally")
          self.create_repo(repo_ext.name, "internal mirror of #{repo_info_ext[:html_url]}")
          ForgeMirror::Git.create_mirror(repo_info_ext[:ssh_url], "git@github.com:#{slug_int}.git", "#{@work_dir}/#{repo_ext.name}")
        end
      end
    end

    def self.create_repo(name, org, description, client)
      ForgeMirror.log.info("Attempting to create repo: #{name}")
      client.create_repository(name, {organization: org, description: description})
    end

    # return an array of names from a sawyer object
    def self.s_name(sobj)
      names = []

      sobj.each do |s|
        names << s[:name]
      end

      names
    end
  end
end
