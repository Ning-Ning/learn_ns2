set ns [new Simulator] 
set cir0       30000; # �趨�����õĲ���CIR
set cir1       30000; # ͬ��
set pktSize    1000 ;#����С
set NodeNb       20; # �趨Դ�ڵ����Ŀ
set NumberFlows 160 ; # ÿ��Դ�ڵ��ϵ���������Ŀ
set sduration   25; # ģ�����ʱ��

#����NAM��ʾ����������ʾ����ɫ
$ns color 1 Blue
$ns color 2 Red
$ns color 3 Green
$ns color 4 Brown
$ns color 5 Yellow
$ns color 6 Black
#����ģ������¼�ļ�                   
set Out [open Out.ns w];   # ���ļ���¼����ʧ��ʱ�����ݴ������������ṹ����
set Conn [open Conn.tr w]; # ���ļ���¼��ǰ������
set tf   [open out.tr w];  # ����Trace�ļ�
$ns trace-all $tf    
set file2 [open out.nam w];# NAM�����ļ�
# $ns namtrace-all $file2 

#�������˽ṹ
set D    [$ns node]  ;#����Ŀ�Ľڵ�(�ڵ�0)
set Ed   [$ns node]  ;#�����Ե·�����ڵ㣨�ڵ�1��
set Core [$ns node]  ;#�������·�����ڵ�(�ڵ�2)

#�趨ƿ����·����������������·�ֱ��趨����ͬ������ò�ͬ�Ķ�������
set flink [$ns simplex-link $Core $Ed 10Mb 1ms dsRED/core] ;#����·��������
$ns queue-limit  $Core $Ed  100
$ns simplex-link $Ed $Core 10Mb 1ms dsRED/edge             ;#��Ե·��������
$ns duplex-link  $Ed   $D  10Mb   0.01ms DropTail          ;#��Ե·������Ŀ�Ľڵ����·

#��������20��ҵ��Դ�ڵ�ͱ�Ե·�����ڵ�
for {set j 1} {$j<=$NodeNb} { incr j } {
 set S($j) [$ns node]
 set E($j) [$ns node]
 $ns duplex-link  $S($j) $E($j)  6Mb   0.01ms DropTail    ;#Դ�ڵ����Ե·��������·
 $ns simplex-link $E($j) $Core   6Mb   0.1ms dsRED/edge   ;#��Ե������·����������
 $ns simplex-link $Core  $E($j)  6Mb   0.1ms dsRED/core   ;#���ĵ���Ե·����������
 $ns queue-limit $S($j) $E($j) 100
}

#����Diffserv����
set qEdC    [[$ns link $Ed $Core] queue]                 ;#ȥ��Ե������·�����Ķ���ʵ�����趨
$qEdC       meanPktSize 40                               ;#ƽ������С
$qEdC   set numQueues_   1                               ;#���������Ŀ
$qEdC    setNumPrec      2                               ;#���������Ŀ
for {set j 1} {$j<=$NodeNb} { incr j } {
 #�趨��Ŀ�Ľڵ㵽����Դ�ڵ��20�������������õĲ���
 $qEdC addPolicyEntry [$D id] [$S($j) id] TSW2CM 10 $cir0 0.02
}

$qEdC addPolicerEntry TSW2CM 10 11                        ;#�趨�ӱ�Ե������·������·���������õĲ���
$qEdC addPHBEntry  10 0 0                                 ;#���PHB����
$qEdC addPHBEntry  11 0 1                                 ;#���PHB����
$qEdC configQ 0 0 10 30 0.1                               ;#�趨�ö��еĲ���
#������������ֱ��Ƕ��кš�������кš���С��ֵminth�������ֵmaxth��maxp
$qEdC configQ 0 1 10 30 0.1                               ;#ͬ��
#��ģ�������������ԺͲ�������
$qEdC printPolicyTable                                    ;#������Ա�
$qEdC printPolicerTable                                   ;#�����������
#��Ӧ�أ��趨�Ӻ��ĵ���Ե·�����ڵ���·���������õĲ���
set qCEd    [[$ns link $Core $Ed] queue]                  ;#ȡ����ʵ��
# set qCEd    [$flink queue]
$qCEd     meanPktSize $pktSize
$qCEd set numQueues_   1                                   ;#�趨���в���
$qCEd set NumPrec       2                                  ;#����PHB����
$qCEd addPHBEntry  10 0 0 
$qCEd addPHBEntry  11 0 1 
$qCEd setMREDMode RIO-D                                     ;#�趨�����������
$qCEd configQ 0 0 15 45  0.5 0.01                           ;#���ö��в���
$qCEd configQ 0 1 15 45  0.5 0.01

#ͬ���趨��������Դ�ڵ������ı�Ե·�����ڵ�����Ľڵ���·����·���в��� 
for {set j 1} {$j<=$NodeNb} { incr j } {
 set qEC($j) [[$ns link $E($j) $Core] queue]                ;#��Ե������
 $qEC($j) meanPktSize $pktSize
 $qEC($j) set numQueues_   1
 $qEC($j) setNumPrec      2
 $qEC($j) addPolicyEntry [$S($j) id] [$D id] TSW2CM 10 $cir1 0.02
 $qEC($j) addPolicerEntry TSW2CM 10 11
 $qEC($j) addPHBEntry  10 0 0 
 $qEC($j) addPHBEntry  11 0 1 
# $qEC($j) configQ 0 0 20 40 0.02
 $qEC($j) configQ 0 0 10 20 0.1
 $qEC($j) configQ 0 1 10 20 0.1
#��ģ�������������ԺͲ�������
$qEC($j) printPolicyTable
$qEC($j) printPolicerTable
#�趨�Ӻ��ĵ���Ե·�����ڵ����·���еĲ���
 set qCE($j) [[$ns link $Core $E($j)] queue]
 $qCE($j) meanPktSize      40
 $qCE($j) set numQueues_   1
 $qCE($j) setNumPrec      2
 $qCE($j) addPHBEntry  10 0 0 
 $qCE($j) addPHBEntry  11 0 1 
# $qCE($j) configQ 0 0 20 40 0.02
 $qCE($j) configQ 0 0 10 20 0.1
 $qCE($j) configQ 0 1 10 20 0.1

}
#�趨���������ļ���ѡ��
set monfile [open mon.tr w]         ;#�����ļ�
set fmon [$ns makeflowmon Fid]      ;#��������Ǵ���һ���������ļ��Ӷ���
$ns attach-fmon $flink $fmon        ;#�����Ӷ�������Ҫ���ӵ���·����
$fmon attach $monfile               ;#�����Ӽ�¼�ļ�����Ӷ������

#����������TCPԴ��Ŀ�Ĵ����Լ�����֮�������
for {set i 1} {$i<=$NodeNb} { incr i } {
for {set j 1} {$j<=$NumberFlows} { incr j } {
set tcpsrc($i,$j) [new Agent/TCP/Newreno]  ;#����TCP����
set tcp_snk($i,$j) [new Agent/TCPSink]     ;#����TCP������
set k [expr $i*1000 +$j];
$tcpsrc($i,$j) set fid_ $k                 ;#�趨�����fid
$tcpsrc($i,$j) set window_ 2000            ;#�趨���ڴ�С
$ns attach-agent $S($i) $tcpsrc($i,$j)
$ns attach-agent $D $tcp_snk($i,$j)
$ns connect $tcpsrc($i,$j) $tcp_snk($i,$j) ;#����Դ��Ŀ�Ĵ���
set ftp($i,$j) [$tcpsrc($i,$j) attach-source FTP];#��TCP�����з���ftpҵ������
} }
# ׼��һ�������������
set rng1 [new RNG]
$rng1 seed 22

# ����ָ���ֲ�����һ�����������趨ÿ��Դ�ڵ��TCP����ʱ����
set RV [new RandomVariable/Exponential]
$RV set avg_ 0.2
$RV use-rng $rng1 

# ����Paretoģ�Ͳ���һ�����������ָ��һ����Ҫ������ļ���С
set RVSize [new RandomVariable/Pareto]
$RVSize set avg_ 10000 
$RVSize set shape_ 1.25
$RVSize use-rng $rng1
set t [$RVSize value]

# �趨���俪ʼʱ��ʹ��ʹ�С���Ự�ĵ�����Ӳ��ɹ���
for {set i 1} {$i<=$NodeNb} { incr i } {
     set t [$ns now]
     for {set j 1} {$j<=$NumberFlows} { incr j } {
	 # ��������Դ�������������趨��һ�δ��俪ʼʱ��
	 $tcpsrc($i,$j) set sess $j
	 $tcpsrc($i,$j) set node $i
	 set t [expr $t + [$RV value]]  ;#�������ʱ��
	 $tcpsrc($i,$j) set starts $t
         $tcpsrc($i,$j) set size [expr [$RVSize value]] ;#���������С
  $ns at [$tcpsrc($i,$j) set starts] "$ftp($i,$j) send [$tcpsrc($i,$j) set size]" ;#���ȴ���
  $ns at [$tcpsrc($i,$j) set starts ] "countFlows $i 1" ;#����������

}}
#��ʼ��������
for {set j 1} {$j<=$NodeNb} { incr j } {
set Cnts($j) 0
}   

#����һ��ÿ��������ֹʱ���õĹ��� 
Agent/TCP instproc done {} {                         ;#�ù���ΪTCP�����ʵ������
global tcpsrc NodeNb NumberFlows ns RV ftp Out tcp_snk RVSize 
# ��$Out������ļ��м�¼������Ϣ(ÿ�а���) :     
# �ڵ㡢�Ự����ʼʱ�䡢����ʱ�䡢����ʱ�䡢����İ�����������ֽ���
# �ش��ֽ�����������  
  set duration [expr [$ns now] - [$self set starts] ] 
  set i [$self set node] 
  set j [$self set sess] 
  set time [$ns now] 
  puts $Out "$i \t $j \t $time \t\
      $time \t $duration \t [$self set ndatapack_] \t\
      [$self set ndatabytes_] \t [$self set  nrexmitbytes_] \t\
      [expr [$self set ndatabytes_]/$duration ]"    
	  # ��������������Ŀ
      countFlows [$self set node] 0

}

#����һ������������Ŀ�ĵݹ���̣�ÿ0.2s����������$Conn������ļ���
proc countFlows { ind sign } {
global Cnts Conn NodeNb
set ns [Simulator instance]
      if { $sign==0 } { set Cnts($ind) [expr $Cnts($ind) - 1] 
} elseif { $sign==1 } { set Cnts($ind) [expr $Cnts($ind) + 1] 
} else { 
  puts -nonewline $Conn "[$ns now] \t"
  set sum 0
  for {set j 1} {$j<=$NodeNb} { incr j } {
    puts -nonewline $Conn "$Cnts($j) \t"
    set sum [expr $sum + $Cnts($j)]
  }
  puts $Conn "$sum"
  puts $Conn ""
  $ns at [expr [$ns now] + 0.2] "countFlows 1 3"
puts "in count"
} }

#ͬ������һ��"finish"���̽���ģ��
proc finish {} {
        global ns tf file2
        $ns flush-trace
        close $file2 
        exit 0
}         

$ns at 0.5 "countFlows 1 3"
$ns at [expr $sduration - 0.01] "$fmon dump"             ;#�����Զ��еļ���
$ns at [expr $sduration - 0.001] "$qCEd printStats"      ;#������Ķ��е�ͳ������
$ns at $sduration "finish"


$ns run


