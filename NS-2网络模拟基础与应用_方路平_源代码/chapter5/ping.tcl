# ����һ��ģ����

set ns [new Simulator]

# �趨��ɫ
$ns color 1 Blue

$ns color 2 Red

 # ��һ��nam  
set nf [open out.nam w]

$ns namtrace-all $nf


# ��������
   proc finish {} {
           global ns nf

           $ns flush-trace

           close $nf

           exec nam out.nam &

           exit 0

   }

# ���������ڵ�
   set n0 [$ns node]

   set n1 [$ns node]

   set n2 [$ns node]


# ������·
   $ns duplex-link $n0 $n1 1Mb 10ms DropTail

   $ns duplex-link $n1 $n2 1Mb 10ms DropTail

# �趨�ڵ�λ��

   $ns duplex-link-op $n0 $n1 orient right

   $ns duplex-link-op $n1 $n2 orient right



# =========================== RTT ================================

# Define a 'recv' function for the class 'Agent/Ping'

   Agent/Ping instproc recv {from rtt} {

    $self instvar node_

    puts "node [$node_ id] received ping answer from $from with round-trip-time $rtt ms."

   }

# =========================== RTT ================================

# ���� Ping0 �� agent
   set p0 [new Agent/Ping]
# �趨��ɫΪ��ɫ
   $p0 set class_ 1
# n0-node Ϊ Ping Э��
   $ns attach-agent $n0 $p0


# ���� Ping1 �� agent
   set p1 [new Agent/Ping]
# �趨��ɫΪ��ɫ
   $p1 set class_ 2
# n2-node Ϊ Ping Э��
   $ns attach-agent $n2 $p1


# ���������ڵ�Э��
   $ns connect $p0 $p1

# �����¼�����ʱ��
   $ns at 0.2 "$p0 send"

   $ns at 0.4 "$p1 send"

   $ns at 0.6 "$p0 send"

   $ns at 0.6 "$p1 send"

   $ns at 1.0 "finish"

# ��ʼ����
   $ns run