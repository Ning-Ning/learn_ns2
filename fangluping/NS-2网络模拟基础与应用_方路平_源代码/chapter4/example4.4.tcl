#�ļ���:example4.4.tcl         
#�趨ģ��ʹ�õ�һЩ����
set val(chan) Channel/WirelessChannel    ;#�ŵ�����
set val(prop) Propagation/TwoRayGround   ;#���ߴ���ģʽ
set val(netif) Phy/WirelessPhy           ;#����ӿ�ģ��
set val(mac)   Mac/802_11                ;#MAC����
set val(ifq)   Queue/DropTail/PriQueue   ;#�ӿڶ�������
set val(ll)    LL                        ;#�߼���·������
set val(ant)   Antenna/OmniAntenna       ;#��������
set val(ifqlen) 50                       ;#�ӿڶ�����󳤶�
set val(nn)   3                          ;#�ƶ��ڵ����Ŀ
set val(rp)   DSDV                       ;#·��Э��
set val(x)    500                        ;#�ƶ����˵Ŀ��
set val(y)    400                        ;#�ƶ����˵ĳ���
set val(stop) 150                        ;#ģ��ʱ��
#��ʼ��ģ������͸��ٶ���
set ns [new Simulator]
set tracefd [open simple.tr w]
set windowVsTime2 [open win.tr w]
set namtrace [open simwrls.nam w]
$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)
#�����ƶ�����
set topo [new Topography]
#�趨�ƶ�������Χ
$topo load_flatgrid $val(x) $val(y)
set chan [new $val(chan)]
#����God����
create-god $val(nn)
#����$val(nn)���ƶ��ڵ㲢���������ӵ��ŵ�
$ns node-config -adhocRouting $val(rp) \
                -llType       $val(ll) \
                -macType      $val(mac) \
                -ifqType      $val(ifq) \
                -ifqLen       $val(ifqlen) \
                -antType      $val(ant) \
                -propType     $val(prop) \
                -phyType      $val(netif) \
                -channel      $chan \
                -topoInstance $topo \
                -agentTrace   ON \
                -routerTrace  ON \
                -macTrace     ON \
                -movementTrace ON 
#�����ƶ��ڵ�
for {set i 0} {$i < $val(nn)} {incr i} {
    set node_($i) [$ns node]
}

#�����ƶ��ڵ�ĳ�ʼλ��
$node_(0) set X_ 5.0        ;#�趨�ڵ�0�ĳ�ʼλ��(5,5,0)
$node_(0) set Y_ 5.0
$node_(0) set Z_ 0.0
$node_(1) set X_ 490.0      ;#�趨�ڵ�1�ĳ�ʼλ��(490,285,0)
$node_(1) set Y_ 285.0
$node_(1) set Z_ 0.0
$node_(2) set X_ 150.0      ;#�趨�ڵ�2�ĳ�ʼλ��(150,240,0)
$node_(2) set Y_ 240.0
$node_(2) set Z_ 0.0
#�趨�ƶ�ģʽ
#��10s �ڵ�0��3.0m/s�ٶ���250,250,0���ƶ�����������
$ns at 10.0 "$node_(0) setdest 250.0 250.0 3.0"
$ns at 15.0 "$node_(1) setdest 45.0 285.0 5.0"
$ns at 110.0 "$node_(0) setdest 480.0 300.0 5.0"
#�ڽڵ�node_(0)��node_(1)֮�䴴��TCP����
set tcp [new Agent/TCP/Newreno]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns attach-agent $node_(0) $tcp
$ns attach-agent $node_(1) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 10.0 "$ftp start"
#����ͳ�ƴ��ڴ�С�Ĺ���
proc plotWindow {tcpSource file} {
     global ns
     set time 0.01
     set now [$ns now]
     set cwnd [$tcpSource set cwnd_]
     puts $file "$now $cwnd"
     $ns at [expr $now+$time] "plotWindow $tcpSource $file"
}
$ns at 10.1 "plotWindow $tcp $windowVsTime2"
#������nam���ƶ��ڵ���ʾ�Ĵ�С������nam���޷���ʾ�ڵ�
for {set i 0} {$i<$val(nn)} {incr i} {
  $ns initial_node_pos $node_($i) 30
}
#ģ�����������ڵ�
for {set i 0} {$i<$val(nn)} {incr i} {
  $ns at $val(stop) "$node_($i) reset";
}
#��������ģ����̵�����
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at 150.01 "puts \"end simulation\";$ns halt"
proc stop {} {  
    global ns tracefd namtrace
    $ns flush-trace
    close $tracefd
    close $namtrace
 }
$ns run
