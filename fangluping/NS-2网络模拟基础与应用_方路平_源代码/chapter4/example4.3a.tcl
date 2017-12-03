#�ļ���:example4.3a.tcl         ;����·��ģ��
set ns [new Simulator]
$ns color 1 Blue
$ns color 2 Red
set file1 [open out.tr w]
$ns trace-all $file1
set file2 [open out.nam w]
$ns namtrace-all $file2
proc finish {} {          ;#�����������
    global ns file1 file2
    $ns flush-trace
    close $file1
    close $file2
    exec nam out.nam &
    exit 0
}
$ns rtproto DV             ;#�趨����·�ɲ���ΪDV������Ҳ��������Ϊ����·�ɲ���
set n0 [$ns node]          ;#�����ڵ�
set n1 [$ns node]          ;#�����ڵ�
set n2 [$ns node]          ;#�����ڵ�
set n3 [$ns node]          ;#�����ڵ�
set n4 [$ns node]          ;#�����ڵ�
set n5 [$ns node]          ;#�����ڵ�
$ns duplex-link $n0 $n1 0.3Mb 10ms DropTail  ;#������·
$ns duplex-link $n1 $n2 0.3Mb 10ms DropTail 
$ns duplex-link $n2 $n3 0.3Mb 10ms DropTail
$ns duplex-link $n1 $n4 0.3Mb 10ms DropTail
$ns duplex-link $n3 $n5 0.5Mb 10ms DropTail
$ns duplex-link $n4 $n5 0.5Mb 10ms DropTail
$ns duplex-link-op $n0 $n1 orient right
$ns duplex-link-op $n1 $n2 orient right
$ns duplex-link-op $n2 $n3 orient up
$ns duplex-link-op $n1 $n4 orient up-left
$ns duplex-link-op $n3 $n5 orient left-up
$ns duplex-link-op $n4 $n5 orient right-up
set tcp [new Agent/TCP/Newreno]
$ns attach-agent $n0 $tcp
set sink [new Agent/TCPSink/DelAck]
$ns attach-agent $n5 $sink
$ns connect $tcp $sink
$tcp set fid_ 1
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP
$ns rtmodel-at 1.0 down $n1 $n4  ;#�趨�ڵ�1��4����·��1.0sʱ�Ͽ�
$ns rtmodel-at 4.5 up $n1 $n4    ;#�趨�ڵ�1��4����·��4.5ʱ���ӻָ�����
$ns at 0.1 "$ftp start"
$ns at 6.0 "finish"
$ns run
