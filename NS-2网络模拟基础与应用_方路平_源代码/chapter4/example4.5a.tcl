#�ļ���:example4.5a.tcl;DropTail���й���ģ�� 
#ģ��ǰ��׼�����������������
set ns [new Simulator]
set nf [open out.nam w]
$ns namtrace-all $nf
set tf [open out.tr w]
set windowVsTime [open win w]
set param [open parameters w]
$ns trace-all $tf
#����һ��'finsh'����
proc finish {} {  
    global ns nf tf windowVsTime param
    $ns flush-trace
    close $nf
    close $tf
    close $windowVsTime
    close $param
    exec nam out.nam &
    exit 0
 }
#����Ŀ�Ľڵ��ƿ����·
set n2 [$ns node]
set n3 [$ns node]
$ns duplex-link $n2 $n3 0.7Mb 20ms DropTail       ;#��ע1
set NumbSrc 3                                     ;#�趨����Դ�ڵ����Ŀ
set Duration 50                                   ;#�趨ģ������ʱ��
#����Դ�ڵ�
for {set j 1} {$j<=$NumbSrc} {incr j} {
set S($j) [$ns node]
}
#����һ�������������������ָ����Դ�ڵ�ftp���ݷ���ʱ����趨ƿ����·ʱ��
set rng [new RNG]                                 ;#����һ�����������
$rng seed 2                                       ;#�趨����
#����һ�����������Ϊ�趨ftp��ʼʱ��Ĳ���
set RVstart [new RandomVariable/Uniform]         ;#�趨�����������
$RVstart set min_ 0                              ;#�趨��Сֵ
$RVstart set max_ 7                              ;#�趨���ֵ
$RVstart use-rng $rng                            ;#ʹ�øղ�ʹ�õ���������������
#ʹ����������趨ÿ������Դ��ftp��ʼʱ��
for {set i 1} {$i<=$NumbSrc} {incr i} {
  set startT($i) [expr [$RVstart value]]         ;#����һ��ʵ��ʹ�õ������
  set dly($i) 1
  puts $param "startT($i) $startT($i) sec"                   ;#�����ǰ�������ֵ
}
#����Դ�ڵ���ƿ���ڵ����·
for {set j 1} {$j<=$NumbSrc} {incr j} {
  $ns duplex-link $S($j) $n2 10Mb $dly($j)ms DropTail ;#�趨ʱ�ӺͶ�������
  $ns queue-limit $S($j) $n2 20                       ;#�趨���д�С
}
#�������ڵ���nam�е���ʾλ��
$ns duplex-link-op $S(2) $n2 orient right
$ns duplex-link-op $n2 $n3 orient right
$ns duplex-link-op $n2 $S(1) orient left-up
$ns duplex-link-op $S(3) $n2 orient right-up
#��ƿ����·�Ķ��д�С�趨Ϊ100
$ns queue-limit $n2 $n3 100
#�趨TCP Sources
for {set j 1} {$j<=$NumbSrc} {incr j} {
    set tcp_src($j) [new Agent/TCP/Reno]
    $tcp_src($j) set window_ 8000
}
#�趨TCP Destinations
for {set j 1} {$j<=$NumbSrc} {incr j} {
    set tcp_src($j) [new Agent/TCP/Reno]
    $tcp_src($j) set window_ 8000 
}
#�趨TCP Destinations
for {set j 1} {$j<=$NumbSrc} {incr j} {
    set tcp_snk($j) [new Agent/TCPSink]
}
#������������ͨ·
for {set j 1} {$j<=$NumbSrc} {incr j} {
    $ns attach-agent $S($j) $tcp_src($j)
    $ns attach-agent $n3 $tcp_snk($j)
    $ns connect $tcp_src($j) $tcp_snk($j)
}
#����FTP sources
for {set j 1} {$j<=$NumbSrc} {incr j} {
    set ftp($j) [$tcp_src($j) attach-source FTP]    
}
#�趨TCP����Դ�İ���С
for {set j 1} {$j<=$NumbSrc} {incr j} {
    $tcp_src($j) set packetSize_ 552
}
#��������FTPԴ�ķ��ͺ�ֹͣ�����¼�
for {set i 1} {$i<=$NumbSrc} {incr i} {
$ns at $startT($i) "$ftp($i) start"
$ns at $Duration "$ftp($i) stop"
} 
#����һ������ʵʱ���ڴ�С��Tcl����
proc plotWindow {tcpSource file k} {
    global ns NumbSrc
    set time 0.03                                           ;#�趨ȡ��ʱ����Ϊ0.03
    set now [$ns now]
    set cwnd [$tcpSource set cwnd_]                         ;#��ȡ��ǰTCP���ڴ�Сcwnd_
    if {$k==1} {
       puts -nonewline $file "$now\t$cwnd\t"              ;#��һ��TCPԴʱ�������һ�С��ڶ���
    } else {
       if {$k<$NumbSrc} {
       puts -nonewline $file "$cwnd\t"}               
   }
   if {$k==$NumbSrc} {                                      ;#���һ��TCPԴʱ���ļ��еļ�¼����
   puts -nonewline $file "$cwnd \n"}
   $ns at [expr $now+$time] "plotWindow $tcpSource $file $k" ;#��ʱ�ݹ��������
}
#���ƹ�����0.1sʱ��һ�ε��ã���ÿ��TCPԴ������һ��
for {set j  1} {$j<=$NumbSrc} {incr j} {
  $ns at 0.1 "plotWindow $tcp_src($j) $windowVsTime $j"
}
#�򿪶��и����ļ���ʵʱ����
$ns monitor-queue $n2 $n3 [open queue.tr w] 0.05            ;#��ע2
[$ns link $n2 $n3] queue-sample-timeout
#��������ģ����̵�����
$ns at 0.0 "$n2 label n2"
$ns at 0.0 "$S(1) label S(1)"
$ns at 0.0 "$S(2) label S(2)"
$ns at 0.0 "$S(3) label S(3)"
$ns at [expr $Duration] "finish"
$ns run
