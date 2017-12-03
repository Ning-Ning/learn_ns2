#�ļ���:example4.2.tcl         ;LANģ��
set opt(tr) "out.tr"           ;#Trace�ļ���
set opt(namtr) "lantest.nam"   ;#Nam��ʾ�ļ���
set opt(stop)  5               ;#��������ʱ��
set opt(node)  8               ;#�趨�������еĽڵ���Ŀ
set opt(qszie) 100             ;#���д�С
set opt(bw)    10Mb            ;#����������
set opt(delay) 10ms            ;#ʱ��
set opt(ll)    LL              ;#LL��Э��
set opt(ifq)   Queue/DropTail  ;#��������
set opt(mac)   Mac/802_3       ;#MAC֡��ʽ����
set opt(chan)  Channel         ;#�ŵ�����
set opt(tcp)   TCP/Reno        ;#TCP�汾
set opt(sink)  TCPSink         ;#TCP������
set opt(app)   FTP             ;#Ӧ�ò�Э��
#�����������
proc finish {} {
    global ns opt trfd
    $ns flush-trace
    close $trfd
    exec nam lantest.nam &
    exit 0
}
#����Trace����
proc create-trace {} {
   global ns opt
   if [file exists $opt(tr)] {
      catch "exec rm -f $opt(tr) $opt(tr) -bw [glob $opt(tr) *]"
   }
   set trfd [open $opt(tr) w]
   $ns trace-all $trfd
   if {$opt(namtr)!=""} {
      $ns namtrace-all [open $opt(namtr) w]  
   }
   return $trfd
}
#����LAN���˽����������
proc create-topology {} {
    global ns opt
    global lan node source node0
    set num $opt(node)  ;#�ڵ���Ŀ
    for {set i 0} {$i<$num} {incr i} {
    set node($i) [$ns node]    ;#����LAN�еĸ����ڵ�
    lappend nodelist $node($i) ;#������뵽nodelist����
    }
    #����LanNode
    set lan [$ns newLan $nodelist $opt(bw) $opt(delay) \
    -llType $opt(ll) \
    -ifqType $opt(ifq) \
    -macType $opt(mac) \
    -chanType $opt(chan)]  ;#���漸���ǲ���args����
   set node0 [$ns node]    ;#������ͨ�ڵ�
   $ns duplex-link $node0 $node(0) 2Mb 2ms DropTail
   $ns duplex-link-op $node0 $node(0) orient right
}
##  �����򲿷�  ##
set ns [new Simulator]
set trfd [create-trace]    ;#�趨trace
create-topology            ;#�趨����ģ������
#��������TCP����
set tcp0 [$ns create-connection TCP/Reno $node(7) TCPSink $node0 0]
$tcp0 set window_ 32
set ftp0 [$tcp0 attach-app FTP]
set tcp1 [$ns create-connection TCP/Reno $node(2) TCPSink $node0 0]
$tcp1 set window_ 32
set ftp1 [$tcp1 attach-app FTP]
set tcp2 [$ns create-connection TCP/Reno $node(4) TCPSink $node0 0]
$tcp2 set window_ 32
set ftp2 [$tcp1 attach-app FTP]
#��������
$ns at 0.0 "$ftp0 start"    ;#��һ�����ݷ���
$ns at 0.0 "$ftp1 start"    ;#�ڶ������ݷ���
$ns at 0.0 "$ftp2 start"    ;#���������ݷ���
$ns at $opt(stop) "finish"
$ns run
