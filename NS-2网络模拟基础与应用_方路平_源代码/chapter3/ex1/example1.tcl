#����һ������Ķ���
set ns [new Simulator]
#��Բ�ͬ�����������岻ͬ����ɫ������Nam��ʾʱʹ�õ�
$ns color 1 blue
$ns color 2 red
#��һ��Nam Trace�ļ�
set nf [open out.nam w]
$ns namtrace-all $nf
#��һ��Trace�ļ���������¼���鴫�͵Ĺ���
set nd [open out.tr w]
$ns trace-all $nd
#����һ�������ĳ���
proc finish {} {
     global ns nf nd
     $ns flush-trace
     close $nf
     close $nd
     exec nam out.nam &
     exit 0
}
#�����ĸ�����ڵ�
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
#����˫����·���ѽڵ���������
$ns duplex-link $n0 $n2 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n2 $n3 1.7Mb 20ms DropTail
#�趨n2��ns3֮����д�СΪ10�������С
$ns queue-limit $n2 $n3 10
#�趨�ڵ��λ�ã�����Ҫ��Nam�õ�
$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right
#�۲�n2��n3֮����еı仯������Ҫ��Nam�õ�
$ns duplex-link-op $n2 $n3 queuePos 0.5
#����һ��TCP������
set tcp [new Agent/TCP]
$tcp set class_ 2
$ns attach-agent $n0 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n3 $sink
$ns connect $tcp $sink
#��NAM�У�TCP�����ӻ�����ɫ��ʾ
$tcp set fid_ 1
#��TCP����֮�Ͻ���FTPӦ�ó���
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP
#����һ��UDP������
set udp [new Agent/UDP]
$ns attach-agent $n1 $udp
set null [new Agent/Null]
$ns attach-agent $n3 $null
$ns connect $udp $null
#��Nam��,UDP�����ӻ��Ժ�ɫ��ʾ
$udp set fid_ 2
#��UDP����֮�Ͻ���CBRӦ�ó���
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 1mb
$cbr set random_ false
#�趨FTP��CBR���ݴ��Ϳ�ʼ�ͽ���ʱ��
$ns at 0.1 "$cbr start"
$ns at 1.0 "$ftp start"
$ns at 4.0 "$ftp stop"
$ns at 4.5 "$cbr stop"
#��ģ�⻷���У�5s�����finish����������ģ��
$ns at 5.0 "finish"
#ִ��ģ��
$ns run
