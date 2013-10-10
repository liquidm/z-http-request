require 'helper'

requires_connection do

  requires_port(8080) do
    describe ZMachine::HttpRequest do

      # ssh -D 8080 igvita
      let(:proxy) { {:proxy => { :host => '127.0.0.1', :port => 8080, :type => :socks5 }} }

      it "should use SOCKS5 proxy" do
        ZMachine.run {
          http = ZMachine::HttpRequest.new('http://jsonip.com/', proxy).get

          http.errback { failed(http) }
          http.callback {
            http.response_header.status.should == 200
            http.response.should match('173.230.151.99')
            ZMachine.stop
          }
        }
      end
    end
  end

  requires_port(8081) do
    describe ZMachine::HttpRequest do

      # brew install tinyproxy
      let(:http_proxy) { {:proxy => { :host => '127.0.0.1', :port => 8081 }} }

      it "should use HTTP proxy by default" do
        ZMachine.run {
          http = ZMachine::HttpRequest.new('http://jsonip.com/', http_proxy).get

          http.errback { failed(http) }
          http.callback {
            http.response_header.status.should == 200
            http.response.should match(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
            ZMachine.stop
          }
        }
      end

      it "should auto CONNECT via HTTP proxy for HTTPS requests" do
        ZMachine.run {
          http = ZMachine::HttpRequest.new('https://ipjson.herokuapp.com/', http_proxy).get

          http.errback { failed(http) }
          http.callback {
            http.response_header.status.should == 200
            http.response.should match(/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/)
            ZMachine.stop
          }
        }
      end
    end
  end

end
