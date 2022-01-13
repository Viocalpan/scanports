import os
import net
import time { now }

fn help(ipaddr string) {
   println('Usage: scanports ipaddr[127.0.0.1]')
   println('scanports $ipaddr\r\n')
}

fn scanport(ip string, port int) int {
   mut conn := net.dial_tcp('$ip:$port') or { return 0 }
   conn.close() or {}
   return port
}

fn scanports(ip string, begin int, end int) []int {
   mut res := []int{}
   for port in begin .. end {
      r := scanport(ip, port)
      if r > 0 {
         res << r
      }
   }
   return res
}

fn main() {
   mut host := '127.0.0.1'
   mut listport := []int{}
   if os.args.len == 2 {
      host = os.args[1]
   }

   help(host)

   thrcount := 100
   portb := 1
   porte := 65535
   perportcount := (porte - portb + 1) / (thrcount - 1)
   starttime := now().unix_time_milli()

   mut threads := []thread []int{}
   for t in 1 .. (thrcount - 1) {
      mut pa := portb + perportcount * (t - 1)
      mut pb := portb + perportcount * t - 1
      threads << go scanports(host, pa, pb)
   }
   tp := threads.wait()
   endtime := now().unix_time_milli()

   for p in tp {
      if p.len > 0 {
         for i in p {
            listport << i
         }
      }
   }

   mut ports := 0
   listport.sort()
   for op in listport {
      println('[+] Port $op is open')
      ports = ports + 1
   }

   spend := f64(endtime - starttime) / 1000
   println('Found $ports Ports, time = $spend (s)')
}
