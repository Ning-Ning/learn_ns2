#����ļ�ʵ����ʵ��Ҫ��ĳ������ã��������ò����ɹ���һ������������ļ�
source setRed.tcl    ;#����ִ��setRed.tcl�ļ��е�����
#set packetsize 512 
set packetsize 1500
#�ù��̴���һ���򵥵İ���6���ڵ���������ˣ�����·����r1��r2��link����
proc create_testnet5 {queuetype bandwidth} {
        global ns s1 s2 r1 r2 s3 s4
        set s1 [$ns node]
        set s2 [$ns node]
        set r1 [$ns node]
        set r2 [$ns node]
        set s3 [$ns node]
        set s4 [$ns node]
        $ns duplex-link $s1 $r1 10Mb 2ms DropTail
        $ns duplex-link $s2 $r1 10Mb 3ms DropTail
        $ns duplex-link $s3 $r2 10Mb 10ms DropTail
        $ns duplex-link $s4 $r2  $bandwidth 5ms DropTail
        #queuetype������ֵΪRED��CBQ/WRR
        $ns simplex-link $r1 $r2 1.5Mb 3ms $queuetype
        $ns simplex-link $r2 $r1 1.5Mb 3ms DropTail
        set redlink [$ns link $r1 $r2]
        [[$ns link $r2 $r1] queue] set limit_ 100
        [[$ns link $r1 $r2] queue] set limit_ 100
        return $redlink
}
#�����������Ͷ������ö�������
#ע����ж�����������Ͷ���Ĳ�ͬ
proc make_queue {cl qt qlim} {  ;#CBQClass queuetype qlimit
         set q [new Queue/$qt]
         $q set limit_ $qlim
         $cl install-queue $q
}
#����CBQ/WRR��������������ö������ƿ����·��
proc create_flat {link qtype qlim number} {
        set topclass_ [new CBQClass]
        $topclass_ setparams none 0 0.98 auto 8 2 0
        #��CBQClass�������link����
        $link insert $topclass_
        set share [expr 100./$number]
        for {set i 0} {$i<$number} {incr i 1} {
                set cls [new CBQClass]
                $cls setparams $topclass_ true .$share auto 1 1 0
                make_queue $cls $qtype $qlim
                $link insert $cls  ;#CBQ/WRR���������·
                $link bind $cls $i
        }
}
# �ù��̴�����һ�����������������������ƿ����·redlink�ϣ���ͳ����Ϣ�����ļ�
#data.f�У�dump����ת����������ݵ�Tclͨ����
proc create_flowstats {redlink stoptime } {
        global ns r1 r2 r1fm flowfile
        #����ļ�data.f�����������flowfile,������ļ��Ĳ������ǶԱ���flowfile�Ĳ���
        set flowfile data.f
        set r1fm [$ns makeflowmon Fid] ;#����һ��������������
        set flowdesc [open $flowfile w] 
        $r1fm attach $flowdesc          ;#������¼�ļ����������������
        $ns attach-fmon $redlink $r1fm  ;#��������ƿ����·redlink����
        $ns at $stoptime "$r1fm dump;close $flowdesc"
}
#�ù��̵���Ҫ�����Ǵ����ڵ���TCP��UDP����
#�ù������ձ�new_cbr��new_tcp ���ã�ͨ�����벻ͬ�Ĳ����ֱ𴴽�
#s2��s4��UDP���Ӻ�s1��s3������
proc create-connection-list {s_type source d_type dest pktClass} {
     global ns
     set s_agent [new Agent/UDP]
     set d_agent [new Agent/$d_type]
     $s_agent set fid_ $pktClass
     $d_agent set fid_ $pktClass
     $ns attach-agent $source $s_agent
     $ns attach-agent $dest $d_agent
     $ns connect $s_agent $d_agent
     set cbr [new Application/Traffic/$s_type]
     $cbr attach-agent $s_agent
     return [list $cbr $d_agent] 
}
# new_cbr���̴�����һ��CBRԴ��/Ŀ�Ķ�Ӧ�ò�Ϊ�䴴������
# ʹ��LossMonitor�������������Ľ��գ�ͬʱҲ�Խ��յ����ݽ���ͳ�ƣ�����ձ���������ʧ�������ȡ�
proc new_cbr { startTime source dest pktSize fid dump interval file stoptime } {
        global ns
        set cbrboth [create-connection-list CBR $source LossMonitor $dest $fid]
        set cbr [lindex $cbrboth 0]
        $cbr set packetSize_ $pktSize
        $cbr set interval_ $interval
        set cbrsnk [lindex $cbrboth 1]
        $ns at $startTime "$cbr start"
	if {$dump == 1 } {
              #������ļ�д����ڷ����С����Ϣ
		puts $file "fid $fid packet-size $pktSize"
		$ns at $stoptime "printCbrPkts $cbrsnk $fid $file"
	}
} 

#
#new_tcp���̴�����һ��CBRԴ��/Ŀ�Ķ�Ӧ�ò�Ϊ�䴴������
proc new_tcp { startTime source dest window fid dump size file stoptime } {
        global ns
        #����create-connection���̣�����TCP����
        set tcp [$ns create-connection TCP/Sack1 $source TCPSink/Sack1/DelAck $dest $fid]
        #�趨TCP���ӵ��������ֵ
        $tcp set window_ $window
	 $tcp set tcpTick_ 0.01
        if {$size > 0}  {$tcp set packetSize_ $size }
        #����FTPӦ��ģ�������󣬲���Դ�����
        set ftp [$tcp attach-source FTP]
        $ns at $startTime "$ftp start" ;#����FTPӦ��ģ����
        #����ʱ������printTcpPkts�������������ݵ��ļ�$file�У��˹����ں����н���
        $ns at $stoptime "printTcpPkts $tcp $fid $file"
        #������ļ�д����ڷ����С����Ϣ
        if {$dump == 1 } {puts $file "fid $fid packet-size [$tcp set packetSize_]"}
}
#����printCbrPkts�Ķ��壬npkts_��LossMonitor�����״̬����
#������������ļ���д��ÿ��UDP���յ��İ�
#�������:LossMonitor�������UDP����ʶ�š�����ļ����
proc printCbrPkts { cbrsnk fid file } {
        puts $file "fid $fid total_packets_received [$cbrsnk set npkts_]"
}
#����printTcpPkts�Ķ��壬ack_����߿ɼ���ACK����
#������������ļ���д��ÿ��TCP��������ʶ�ź���߿ɼ���ACK���루ʵ���յ��Ĳ����ظ��ķ��������
#�������:LossMonitor�������UDP����ʶ�š�����ļ����
proc printTcpPkts { tcp fid file } {
        puts $file "fid $fid total_packets_acked [$tcp set ack_]"
}
#ģ�����ʱ��finish_ns ���̹ر�����ļ�
#ģ�����ʱ�����ô˺���
proc finish_ns {f} {
     global ns
     $ns instvar scheduler_
     $scheduler_ halt
     close $f
     puts "simulation complete"
}

#�ù������ڶ�����ص�����ļ�(data.f)���з���������ͳ�ƽ��д������ļ�
#�������:�����ļ�������ļ���CBR������������TCP����������
# data.f���ļ���ʽ���£�����17��:
# time fid($2) c=forced/unforced type class src dest pktA (��$8)byteA CpktD CbyteD
#    TpktA TbyteA TCpktD TCbyteD TpktD TbyteD pktD(��$18) byteD
# A:arrivals D:drops C:category(forced/unforced) T:totals 
#
# �����ʽ: class # arriving_packets # dropped_packets # 
#��������ʶ��#������ն˵ķ�����Ŀ(���ܰ����ظ�)#�����ķ�����Ŀ
#$8����������������սڵ�ķ����� $18:�������������ķ��������������ڼ�ⶪ���ķ�����
proc finish_flowstats { infile outfile cbrs tcps} {
      set awkCode {
                #������awk����
           BEGIN{
                #������ʼ������,arrivals����ͳ�Ʒ���ĵ�������drops����ͳ�Ʒ���Ķ�����
                arrivals=0;
                drops=0;
                prev=-1;
           }
           {
              if(prev==-1) {
                 arrivals+=$8;
                 drops+=$18;
                 prev=$2;
              }
              else if($2==prev){
                arrivals+=$8;
                drops+=$18;
              }
              else {
                 printf "class %d arriving_pkts %d dropped_pkts %d\n",prev,arrivals,drops;
                 prev=$2;
                 arrivals=$8
                 drops=$18;
              }
           }
          END{
            printf "class %d arriving_pkts %d dropped_pkts %d\n",prev,arrivals,drops;
         }
      }
     puts $outfile "cbrs: $cbrs tcps: $tcps"
    #��Tcl������ִ��$awkCode�����awk���룬������������������ļ���
     exec awk $awkCode $infile >@ $outfile
}
#���������ʾģ����ֹʱ��
proc printstop { stoptime file } {
        puts $file "stop-time $stoptime"
}
#�ù���ͨ������ǰ��Ĺ��̣����ո�����������������һ��ʵ������
#������CBR������Ƶ�ʡ��ڵ�s4��r2�Ĵ�������ļ�(temp.tr)��ƿ����·���е����㷨��CBR���ĸ�����TCP���ĸ���
proc test_simple { interval bandwidth datafile scheduling cbrs tcps} {
	global ns s1 s2 r1 r2 s3 s4  flowfile packetsize
	set testname simple
	set stoptime 100.1
	set printtime 100.0
	set qtype RED
       set qlim 100
       #����ģ��������
       set ns [new Simulator]
       #���ݲ�ͬ�Ķ��е����㷨������ͬ����·�������ö��ж������
       if {$scheduling=="wrr"} {
           #����create_testnet5���̴����������ˣ�����r1��r2��·�Ķ�������ΪCBQ/WRR
           set xlink [create_testnet5 CBQ/WRR $bandwidth]
           #����create_flat��������CBQ/CRR����Ĳ���
           create_flat $xlink DropTail $qlim [expr $cbrs+$tcps]
       } elseif {$scheduling=="fifo"} {
           #����create_testnet5���̴����������ˣ�����r1��r2��·�Ķ�������ΪRED
           set xlink [create_testnet5 RED $bandwidth]
           #����set_Red_Oneway��������r1��r2��·����
           set_Red_Oneway $r1 $r2
       }
	#��ƿ����·�ϴ�������ض���
	create_flowstats $xlink $printtime
	set f [open $datafile w]
	$ns at $stoptime "printstop $printtime $f"
       #����new_cbr���̺�new_tcp���̴���CBRӦ�ú�TCPӦ��
       for {set i 0} {$i<$cbrs} {incr i 1} {
           new_cbr 1.4 $s2 $s4 100 $i 1 $interval $f $printtime
       }
       for {set i $cbrs} {$i<$cbrs+$tcps} {incr i 1} {
           new_tcp 0.0 $s1 $s3 100 $i 1 $packetsize $f $printtime
       }
       #ģ������������������ͳ����Ϣ�����ļ�(data.f)��
       $ns at $stoptime "finish_flowstats $flowfile $f $cbrs $tcps"
       $ns at $stoptime "finish_ns $f"
	puts seed=[ns-random 0]
	$ns run
}

#�ýű��ļ��������򣬸ýű��ļ���Ҫ�������ű����ã����ø�ʽΪ
#exec ns Collapse.tcl simple $interval $bandwidth $scheduling $cbrs $tcps
#�����������������ʾ������Ϣ
if { $argc < 2 || $argc > 6} {
        puts stderr {usage: ns $argv [ arguments ]}
        exit 1
} elseif { $argc == 2 } {
        set testname [lindex $argv 0]
        set interval [lindex $argv 1] 
	set bandwidth 128Kb
	set datafile Collapse.tr
        puts "interval: $interval"
} elseif { $argc == 3 } {
        set testname [lindex $argv 0]
        set interval [lindex $argv 1] 
	set bandwidth [lindex $argv 2]
	set datafile Fairness.tr
        puts "interval: $interval"
} elseif { $argc == 6} {
        set testname [lindex $argv 0]
        set interval [lindex $argv 1] 
	set bandwidth [lindex $argv 2]
      set scheduling [lindex $argv 3]
            set cbrs [lindex $argv 4]
            set tcps [lindex $argv 5]
	set datafile temp.tr
      puts "interval: $interval"
}
if { "[info procs test_$testname]" != "test_$testname" } {
        puts stderr "$testname: no such test: $testname"
}
#���ù���test_simple
test_$testname $interval $bandwidth $datafile $scheduling $cbrs $tcps
#���Ϸ�����Collapse.tcl�Ĵ��룬���ж����������̣��������ĺô��������ڴ���
#�ĸ��ã���Լ�˱��ʱ�䡣��д�Ƚϸ��ӵ�Tcl�ű�����ʱ�����ַ���ֵ�ý��
