#�ļ���: example4.1a.tcl
#���������в������֣�
if {$argc==4} {                  ;#�������������Ĳ�����ĿΪ4����ȡ�������������С�
#argc��OTcl�ı���������C�����г��õ�argc��˼����һ�¡�
set bandwidth [lindex $argv 0]   ;#��һ������Ϊ����(��·����)
set delay [lindex $argv 1]       ;#�ڶ�������Ϊ��·�ӳ�
set window [lindex $argv 2]      ;#����������Ϊ���ڴ�С
set time [lindex $argv 3]        ;#���ĸ�����Ϊģ��ʱ��
} else {                         ;#����������벻��ȷ��������ʾ��Ϣ���˳�
       puts "            bandwidth" 
       puts "  n0---------------------------n1"
       puts " TCP_window         delay" 
       puts "Usage: $argv0 bandwidth delay window simulation_time"    
}
#��������ģ�����
set ns [new Simulator]            ;#����ģ��������ÿ��ģ������½�һ��nsģ����
#��Trace�ļ���¼ģ����
set nf [open out.nam w]
$ns namtrace-all $nf
set ftr [open slidewin.tr w]
$ns trace-all $ftr
#���"finish"�����Թر�ģ������Trace�ļ�������Nam����
proc finish {} {
    global ns nf
    $ns flush-trace
    close $nf
    exec nam out.nam &          ;#"&"��ʾ��̨����
    exit 0
}
#���������ڵ�
set n0 [$ns node]
set n1 [$ns node]
#�������ڵ�䴴��һ����·���õ�����������Ĳ���
#     ��·����   ��� �յ�  ��·����  ��·��ʱ ��������
$ns duplex-link  $n0  $n1  $bandwidth $delay   DropTail
#�趨Nam����ʾʱ��·���ڵ�ĳ�ʼλ�á��ɲ���
$ns duplex-link-op $n0  $n1  orient left-right
#����TCP����
set tcp [$ns create-connection TCP/RFC793edu $n0 TCPSink $n1 1]
#set tcp [$ns create-connection TCP/Reno $n0 TCPSink $n1 1]
#����TCP���ӵ����ԣ��細�ڴ�С������С��
$tcp set window_      $window
$tcp set ssthresh_    60
$tcp set packetSize_  500
#�ڸ�TCP�����ϼ���FTP��Ӧ�ò�ҵ������
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP
#ģ��ʱ�����
$ns at 0.5 "$ftp start" ;#0.5sʱ��ʼ����ftp������
$ns at $time "finish"
set f0 [open cwndrecNoss.tr w]  ;#�򿪼�¼�ļ�
#set f0 [open cwndrec.tr w]     
proc Record {} {                ;#�����¼����
     global f0 tcp ns           ;#����ȫ�ֱ���
     set intval 0.1             ;#�趨��¼���ʱ��
     set now [$ns now]          ;#��ȡ��ǰnsʱ��
     set cwnd [$tcp set cwnd_]  ;#��ȡ��ǰcwndֵ
     puts $f0 "$now $cwnd"      ;#��ʱ����cwndֵ��¼���ļ���
     $ns at [expr $now + $intval] "Record" ;#��ʱ���ü�¼����
}
$ns at 0.1 "Record"             ;#ns�״ε���Record����
#��ʼģ��
$ns run
