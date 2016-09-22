# Using Licensee

## Command line usage

1. `cd` into a project directory
2. Execute the `licensee` command

You'll get an output that looks like:

```
License: MIT
Confidence: 98.42%
Matcher: Licensee::GitMatcher
```

Alternately, `licensee <directory>` will treat the argument as the project directory, and `licensee <file>` will attempt to match the individual file specified, both with output that looks like the above.

## License Ruby API

```ruby
license = Licensee.license "/path/to/a/project"
=> #<Licensee::License name="MIT" match=0.9842154131847726>

license.key
=> "mit"

license.name
=> "MIT License"

license.meta["source"]
=> "http://opensource.org/licenses/MIT"

license.meta["description"]
=> "A permissive license that is short and to the point. It lets people do anything with your code with proper attribution and without warranty."

license.meta["permissions"]
=> ["commercial-use","modifications","distribution","private-use"]
```

## Advanced API usage

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
