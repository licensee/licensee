## Using Licensee

### Command line usage

Licensee has an extensive command line interface. See [the command line documentation](command-line-usage.md) for more information.

### License Ruby API

```ruby
license = Licensee.license "/path/to/a/project"
=> #<Licensee::License name="MIT" match=0.9842154131847726>

license.key
=> "mit"

license.name
=> "MIT License"

license.meta["source"]
=> "https://spdx.org/licenses/MIT.html"

license.meta["description"]
=> "A permissive license that is short and to the point. It lets people do anything with your code with proper attribution and without warranty."

license.meta["permissions"]
=> ["commercial-use","modifications","distribution","private-use"]
```

### Providing an access token

If you wish to scan private GitHub repositories, or are hitting API rate limits, you can configure the embedded [Octokit](https://github.com/octokit/octokit.rb)
client using environment variables, for example:

```sh
OCTOKIT_ACCESS_TOKEN=abc123 licensee https://github.com/benbalter/licensee
```

Octokit can also be configured using standard module-level configuration:

```ruby
# see https://github.com/octokit/octokit.rb#configuring-module-defaults
Octokit.configure do |c|
  c.access_token = "<your 40 char token>"
end

license = Licensee.license "https://github.com/benbalter/licensee"
```

### Advanced API usage

You can gather more information by working with the project object, and the top level Licensee class.

```ruby
 Licensee::VERSION                                 # The Licensee version
 Licensee.licenses                                 # All the licenses Licensee knows about

 project = Licensee.project "/path/to/a/project"   # Get a Project (Git checkout or just local Filesystem) (post 6.0.0)

 project.license                                   # The matched license
 project.matched_file                              # Object for the particular file containing the apparent license
 project.matched_file.filename                     #   Its filename
 project.matched_file.confidence                   #   The confidence level in the license matching
 project.matched_file.content                      #   The content of your license file
 project.license.content                           # The Open Source License text it matched against
```
