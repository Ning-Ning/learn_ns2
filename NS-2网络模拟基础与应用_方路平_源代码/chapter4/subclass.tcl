#file:subclass.tcl ;#��ѯ�����Tcl�ű�Դ��
#Query the subclass for given class ;#��ѯ�����������
if {$argc==1} {
  set motherclass [lindex $argv 0]  ;#��ѯ����ѯ����
} else {
  puts "Usage:$argv0 targetclass"
  exit 1
       }
foreach cl [$motherclass info subclass] {
  puts $cl                          ;#�������ѯ�����������
}