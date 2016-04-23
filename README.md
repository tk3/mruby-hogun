mruby-hogun
=========
mruby-hogun is a convenient library to build the command line interface.

Example
=========

```
class FooCLI < Hogun
  desc "hello NAME", "say hello to NAME"
  option :opt1
  def hello(name)
    puts "Hello #{name}"
  end
end

FooCLI.start
```

License
=========
MIT License

