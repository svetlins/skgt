class Foo
    def foo
        p 'called foo'
    end

    def method_missing method, *args, &block
        p method
    end

    def call_bar
        bar
    end

    def send_bar
        send(:bar)
    end

    def self_send_bar
        self.send(:bar)
    end

    private

    def bar
        p 'called bar'
    end
end

f = Foo.new

f.foo
f.bar
f.call_bar
f.send_bar
f.self_send_bar
f.send(:bar)
