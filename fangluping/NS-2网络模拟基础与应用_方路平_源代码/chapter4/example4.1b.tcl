#��������ģ�����
set ns [new Simulator]            ;#����ģ��������ÿ��ģ������½�һ��nsģ����
#��Trace�ļ���¼ģ����
set nf [open fast-recovery-out.nam w]
$ns namtrace-all $nf
set ftr [open fast-recovery-out.tr w]
$ns trace-all $ftr
#���"finish"�����Թر�ģ������Trace�ļ�������Nam����
proc finish {} {
    global ns nf
    $ns flush-trace
    close $nf
    exec nam fast-recovery-out.nam &   ;#"&"��ʾ��̨����
    exit 0
}

#����4���ڵ�n0 ~ n4
foreach i "0 1 2 3" {
        set n$i [$ns node]
}
#�����ڵ�����·,��n1 ~ n2֮������һ�������С����·
$ns duplex-link $n0 $n1 5Mb 20ms DropTail
$ns duplex-link $n1 $n2 0.5Mb 100ms DropTail
$ns duplex-link $n2 $n3 5Mb 20ms DropTail
#���ö��г�������
$ns queue-limit $n1 $n2 5
#���ýڵ���Nam�еĶ��뷽ʽ
$ns duplex-link-op $n0 $n1 orient right
$ns duplex-link-op $n1 $n2 orient right
$ns duplex-link-op $n2 $n3 orient right
#���ö�����Nam�е���ʾ����
$ns duplex-link-op $n1 $n2 queuePos 0.5
#��Ӵ����TCP������Agent
set tcp [new Agent/TCP/Reno]
$ns attach-agent $n0 $tcp
#��Ӵ����TCP������Agent
set sink [new Agent/TCPSink]
$ns attach-agent $n3 $sink
#���շ�������������
$ns connect $tcp $sink
#�����Ӻõ�TCP�ŵ�������ҵ������������ʹ��FTP
set ftp [new Application/FTP]
$ftp attach-agent $tcp
#���ü�ر���������Nam��ʾʱʵʱ��ʾ��Щ������ֵ
$tcp set nam_tracevar_ true     ;#��Nam�ĸ��ٱ���
$ns add-agent-trace $tcp tcp    ;#������TCP����ĸ��ٲ����ø��ٱ�ǩΪ"tcp"
$ns monitor-agent-trace $tcp    ;#��ظ��ٶ���
$tcp tracevar cwnd_             ;#������Ҫ��صı�������cwndֵ
$tcp tracevar ssthresh_         ;#����������
$tcp tracevar maxseq_           ;#�ѷ��͵��������
$tcp tracevar ack_              ;#���յ������ȷ�����
$tcp tracevar dupacks_          ;#�ظ�ACK������
#���ñ�ǩ����ʾ�͵���ģ�����
$ns at 0.0 "$n0 label TCP"  ;#���ýڵ����ֱ�ǩ
$ns at 0.0 "$n3 label TCP"
$ns at 0.0 "$ns trace-annotate \"TCP Reno:Fast Recovery\"" ;#����ʾ�����������Ϣ
$ns at 0.1 "$ftp start"
$ns at 5.0 "$ftp stop"
$ns at 5.25 "finish"
#��ʼģ��
$ns run
