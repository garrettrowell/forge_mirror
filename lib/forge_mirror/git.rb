require 'rugged'

module ForgeMirror
  class Git
#    # Username needs to be git to clone public repos
#    @cred = Rugged::Credentials::SshKey.new({
#      username: 'git',
#      publickey: ForgeMirror.configuration.git[:public_key],
#      privatekey: ForgeMirror.configuration.git[:private_key],})

    def self.clone_repo(repo_url, clone_path)
      expanded_clone_path = File.expand_path(clone_path)

      if File.directory?(expanded_clone_path)
        ForgeMirror.log.info("#{expanded_clone_path} exists. Attempting to discover .git directory")
        repo = Rugged::Repository.discover(expanded_clone_path)
      else
        ForgeMirror.log.info("Attempting to clone #{repo_url} to #{expanded_clone_path}")
        repo = Rugged::Repository.clone_at(repo_url, expanded_clone_path, {credentials: @cred})
        ForgeMirror.log.info("Successfully cloned #{repo_url}")
      end

      repo
    end

    def self.push_repo(repo, remote_name, ref)
      ForgeMirror.log.debug("Attempting to push to #{remote_name} remote")
      repo.remotes[remote_name].push(ref, {credentials: @cred})
      ForgeMirror.log.info('Successfully pushed')
    end

    def self.add_remote(repo, remote_name, remote_url)
      remote = repo.remotes[remote_name]

      # check to see if remote already configured
      if remote.nil?
        ForgeMirror.log.info("Adding remote #{remote_name}: #{remote_url} to repo")
        repo.remotes.create(remote_name, remote_url)
        ForgeMirror.log.info("Successfully added remote #{remote_name}")
      else
        ForgeMirror.log.info("Remote #{remote_name} already exists")

        # Check if the urls match
        unless remote.url == remote_url
          # should probably exit after a more descriptive message
          ForgeMirror.log.error('Remote urls do not match...')
        end
      end
    end

    def self.update_local(repo, remote_name)
      remote = repo.remotes[remote_name]
      refs   = remote.fetch_refspecs
      remote.fetch(refs, {credentials: @cred})
    end

    def self.create_mirror(repo_url_external, repo_url_internal, clone_path)
      # Username needs to be git to clone public repos
      @cred = Rugged::Credentials::SshKey.new({
        username: 'git',
        publickey: ForgeMirror.configuration.git[:public_key],
        privatekey: ForgeMirror.configuration.git[:private_key],})

      local_repo = clone_repo(repo_url_external, clone_path)
      add_remote(local_repo, 'internal', repo_url_internal)
      update_local(local_repo, 'origin')
      push_repo(local_repo, 'internal', local_repo.ref_names.to_a)
    end
  end
end
