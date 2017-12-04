#��С���о�����TCP����UDP������ƿ����·����ʱ�Ĺ�ƽ������
#�ı�Ĳ�����Ҫ��UDP�ķ����ʴ�һ���ǳ�С��ֵ��������
#��ͼ������finish������

set datafile Fairness.data
#����Fairness1.tcl�ļ��еĴ���
source Fairness1.tcl
#���ղ���
set scheduling [lindex $argv 0]
set cbrs [lindex $argv 1]
set tcps [lindex $argv 2]
set type [lindex $argv 3]
#ʵ������:��typeֵΪ//Collapse",�����������ӵ������ʵ��(��7.1.3),
#���������ǹ�ƽ��ʵ��
if {$type=="Collapse"} {
   set bandwidth 128Kb
} else {
   set bandwidth 10Mb
}
set singlefile temp.tr
set label $type.$scheduling.$cbrs.$tcps
set psfile Fairness.ps

#����ģ��,����Collapse.tcl�ļ�
proc run_sim {bandwidth scheduling cbrs tcps singlefile datafile i} {
     set interval [expr $cbrs *0.0$i]
     puts "ns Collapse.tcl simple $interval $bandwidth $scheduling $cbrs $tcps"
     exec ns Collapse.tcl simple $interval $bandwidth $scheduling $cbrs $tcps 
     append $singlefile $datafile $cbrs $tcps
}
#exec rm -f $datafile
#��interval=0.00008ʱ��CBR��������10Mb/s
#��interval=0.0008ʱ��CBR��������1Mb/s
#���ͼ����0.01��0.09
for {set i 1} {$i<9} {incr i 1} {
     run_sim  $bandwidth $scheduling $cbrs $tcps $singlefile $datafile 00$i
}
for {set i 1} {$i<9} {incr i 1} {
     run_sim  $bandwidth $scheduling $cbrs $tcps $singlefile $datafile $i
}
finish