
load('/Library/Ruby/Gems/1.8/gems/jspec-4.2.1/lib/jspec.js')
load('/Library/Ruby/Gems/1.8/gems/jspec-4.2.1/lib/jspec.xhr.js')
load('public/javascripts/application.js')
load('jspec/unit/spec.helper.js')

JSpec
.exec('jspec/unit/spec.js')
.run({ reporter: JSpec.reporters.Terminal, fixturePath: 'jspec/fixtures' })
.report()