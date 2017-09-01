wifi.setmode(wifi.STATION) 
--Set network mode to station to connect it to wifi router. 
--You can also set it to AP to make it a access point allowing 
--connection from other wifi devices.
--Set a static ip so its easy to access
cfg = {
    ip="192.168.1.6",
    netmask="255.255.255.0",
    gateway="192.168.1.1"
  }
wifi.sta.setip(cfg)
wifi.sta.getmac(cfg)
--Your router wifi network's SSID and password
wifi.sta.config("XXX","YYY")
--Automatically connect to network after disconnection
wifi.sta.autoconnect(1)
--Print network ip address on UART to confirm that network is connected
print(wifi.sta.getip())
----------
outpin=8

if srv~=nil then
srv:close() end

srv=net.createServer(net.TCP) 
srv:listen(8266,function(conn)
    conn:on("receive",function(conn,payload)
--next row is for debugging output only
    print(payload)
    
    function ctrlpower()
    pwm.setup(outpin,50,71) --setup at position 0°
    dotaz=string.sub(payload,kdesi[2]+1,#payload)
    if dotaz =="CLOSE" then pwm.setduty(outpin,27) return end --minus 90 on the left
    if dotaz =="OPEN" then pwm.setduty(outpin,123) return end --plus 90 on the right
    pwm.start(outpin)
    end
    
    --parse position POST value from header
    kdesi={string.find(payload,"pwmi=")}
    --If POST value exist, set LED power
    if kdesi[2]~=nil then 
    ctrlpower()
    end

    conn:send('HTTP/1.1 200 OK\n\n')
    conn:send('<!DOCTYPE HTML>\n')
    conn:send('<html>\n')
    conn:send('<head><meta  content="text/html; charset=utf-8">\n')
    conn:send('<title>ESP8266</title></head>\n')
    conn:send('<body><h1 style="font-family:verdana;">Kiki feeder!</h1>\n')
    conn:send('<h3 style="font-family:courier;"> For testing purposes </h3>\n')
    conn:send('<h3 style="font-family:courier;"> Additional buttons are for food coming out from the tube.</h3>\n')
    conn:send('<form action="" method="POST">\n')
    conn:send('<input type="submit" name="pwmi" value="CLOSE"><br><br>\n')
    conn:send('<input type="submit" name="pwmi" value="OPEN"> <form style="font-family:courier;"><br><br>\n')
    conn:send('<IMG SRC="https://goo.gl/rjEGub" WIDTH="400" HEIGHT="500" BORDER="1"><br><br>\n')
    conn:send('<footer style="font-family:courier;">Emma 1st of September 2017</footer>')
    conn:send('</body></html>\n')
    conn:on("sent",function(conn) conn:close() end)
    end)
end)
