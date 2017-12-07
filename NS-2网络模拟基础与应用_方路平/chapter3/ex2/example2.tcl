#����һЩ����
set val(chan) Channel/WirelessChannel   ;#�����ŵ�����
set val(prop) Propagation/TwoRayGround  ;#�趨���ߴ���ģ��
set val(netif) Phy/WirelessPhy          ;#����ӿ�ģ��
set val(mac)   Mac/802_11               ;#MAC������
set val(ifq)   Queue/DropTail/PriQueue  ;#�ӿڶ�������
set val(ll)    LL                       ;#�߼���·������
set val(ant)   Antenna/OmniAntenna      ;#����ģ��
set val(x)     1000                     ;#�趨���˷�Χ
set val(y)     1000                     ;#�趨���˷�Χ
set val(cp)    ""                       ;#�ڵ��ƶ���ģ���ļ�
set val(sc)    ""
set val(ifqlen) 50                      ;#����ӿڶ��еĴ�С
set val(nn)     3                       ;#������
set val(seed)   0.0 
set val(stop)   1000.0                  ;#ģ�����ʱ��
set val(tr)     exp.tr                  ;#�趨Trace�ļ���
set val(rp)     DSDV                    ;#�趨����·��Э��
set AgentTrace  ON
set RouterTrace ON
set MacTrace    OFF
#��ʼ��ȫ�ֱ���
set ns [new Simulator]
$ns color 1 blue
$ns color 2 red
#��Trace�ļ�
$ns use-newtrace                        ;#ʹ���µ�Trace��ʽ
set namfd [open nam-exp.tr w]
$ns namtrace-all-wireless $namfd $val(x) $val(y)
set tracefd [open $val(tr) w]
$ns trace-all $tracefd
#����һ�����˶���һ��¼�ƶ��ڵ����������ƶ������
set topo [new Topography]
#���˵ķ�ΧΪ1000m*1000m
$topo load_flatgrid $val(x) $val(y)
#���������ŵ�����
set chan [new $val(chan)]
#����God����
set god [create-god $val(nn)]
#�����ƶ��ڵ������
$ns node-config -adhocRouting     $val(rp) \
                -llType           $val(ll) \
                -macType          $val(mac) \
                -ifqType          $val(ifq) \
                -ifqLen           $val(ifqlen) \
                -antType          $val(ant) \
                -propType         $val(prop) \
                -phyType          $val(netif) \
                -channel          $chan \
                -topoInstance      $topo \
                -agentTrace       ON \
                -routerTrace      ON \
                -macTrace         OFF \
                -movementTrace    OFF
for {set i 0} { $i < $val(nn)} {incr i} { ;#$val(nn)=3
             set node($i) [$ns node] ;#����3������ڵ�
             $node($i) random-motion 0 ;#�ڵ㲻����ƶ�
}

#�趨���ƶ��ڵ�ĳ�ʼλ��
#�趨�ڵ�0�ĳ�ʼλ��
$node(0) set X_ 350.0
$node(0) set Y_ 500.0
$node(0) set Z_ 0.0
#�趨�ڵ�1�ĳ�ʼλ�ã�1000*1000�ĳ������ڵ�1λ���м�
$node(1) set X_ 500.0
$node(1) set Y_ 500.0
$node(1) set Z_ 0.0
#�趨�ڵ�2�ĳ�ʼλ��
$node(2) set X_ 650.0
$node(2) set Y_ 500.0
$node(2) set Z_ 0.0
#�ڽڵ�1��2֮����̵�hop��Ϊ1
$god set-dist 1 2 1
#�ڽڵ�0��2֮����̵�hop��Ϊ2
$god set-dist 0 2 2
#�ڽڵ�0��1֮����̵�hop��Ϊ1
$god set-dist 0 1 1
set god [God instance]
#��ģ��ʱ��200sʱ���ڵ�1��ʼ��λ��(500,500)�ƶ���(500,900),�ٶ�Ϊ2.0 m/s
$ns at 200.0 "$node(1) setdest 500.0 900.0 2.0"
#��ģ��ʱ��500sʱ���ڵ�1�ٴ�λ��(500,900)�ƶ���(500,100),�ٶ�Ϊ2.0 m/s
$ns at 500.0 "$node(1) setdest 500.0 100.0 2.0"
#�ڽڵ�0�ͽڵ�2����һ��CBR/UDP�����ӣ�����ʱ��100s��ʱ��ʼ����
set udp(0) [new Agent/UDP]
$udp(0) set fid_ 1
$ns attach-agent $node(0) $udp(0)
set null(0) [new Agent/Null]
$ns attach-agent $node(0) $null(0)
set cbr(0) [new Application/Traffic/CBR]
$cbr(0) set packetSize_ 200
$cbr(0) set interval_ 2.0
$cbr(0) set random_ 1
$cbr(0) set maxpkts_ 10000
$cbr(0) attach-agent $udp(0)
$ns connect $udp(0) $null(0)
$ns at 100.0 "$cbr(0) start"
#��Nam�ж���ڵ��ʼ��С
for {set i 0} {$i < $val(nn)} {incr i} {
                   #ֻ�ж������ƶ�ģ�ͺ�����������ܱ�����
                   $ns initial_node_pos $node($i) 60
}

#����ڵ�ģ��Ľ���ʱ��
for {set i 0} {$i < $val(nn)} {incr i} {
                   $ns at $val(stop) "$node($i) reset"
}

$ns at $val(stop) "stop" ;#$val(stop)ģ��ʱ�����������stop����
$ns at $val(stop) "puts \"NS EXITING...\";$ns halt"
proc stop {} {
   global ns tracefd namfd
   $ns flush-trace
   close $tracefd
   close $namfd
}
puts $tracefd "M 0.0 nn $val(nn) x $val(x) rp $val(rp)" ;#д��ڵ�����ģ�ⳡ����С��·��Э��routing protocol
puts $tracefd "M 0.0 sc $val(sc) cp $val(cp) seed $val(seed)"
puts $tracefd "M 0.0 prop $val(prop) ant $val(ant)"
puts "Starting Simulation..."
$ns run
