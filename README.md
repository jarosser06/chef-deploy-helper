deploy-helper Cookbook
======================
It leaves the application deployment purely in the
hands of the developer.  It provides a clean way to
gather deployment details from an application repo
that can then be used during the primary application
deployment.

This is very basic and only supports git at the moment.

Usage
-----
Add a .deploy.yml file to the git application repo
you plan to use for an application deployment and
use the helper method.

```yaml
---
revision:
  default: master
  production: prod
  staging: staging
  dev: dev
migrate:
  default: false
  proudction: true
```

The helper method returns a mash of the yaml info,
that should represent the Chef environment so if
revision is set for production but not master it
will just use whatever the default is.

```ruby
app_repo = 'git@github.com:jarosser06/magic'
deploy_key = data_bag_item('secrets', 'deploy_key')
app_info = git_deployment_info(app_repo, deploy_key['key'])
```

Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
- Author:: Jim Rosser(jarosser06@gmail.com)

```text
copyright (C) 2015 Jim Rosser

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software,
and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
```
