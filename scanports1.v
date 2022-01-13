import os
import net
import time { now }

fn help(ipaddr string) {
   println('Usage: scanports ipaddr[127.0.0.1]')
   println('scanports $ipaddr\r\n')
}

fn scanport(ip string, port int) int {
   mut conn := net.dial_tcp('$ip:$port') or { return 0 }
//        println("[+] Port $port is open")
   conn.close() or {}
   return port
}

fn main() {
   mut host := '127.0.0.1'
   if os.args.len == 2 {
      host = os.args[1]
   }
   help(host)

   starttime := now().unix_time_milli()
   mut threads := []thread int{}
   for port in 1 .. 65535 {
      threads << go scanport(host, port)
   }
   tp := threads.wait()
   endtime := now().unix_time_milli()
   mut ports := 0
   for p in tp {
      if p > 0 {
         println('[+] Port $p is open')
         ports = ports +1
      }
   }

   spend := f64(endtime - starttime) / 1000
   println('Found $ports Ports, time = $spend (s)')
}
