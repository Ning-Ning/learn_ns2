#���ļ�����Ҫ����������r1��r2֮������������·���������
#���������ֻ�������ڵ�����·
# ʹ���Զ���set_Red_Oneway�������õ�RED����
proc set_Red { node1 node2 } {
	set_Red_Oneway $node1 $node2
	set_Red_Oneway $node2 $node1
}

proc set_Red_Oneway { node1 node2 } {
        global ns
        [[$ns link $node1 $node2] queue] set mean_pktsize_ 1000 ;#�����С��ƽ��ֵ
        [[$ns link $node1 $node2] queue] set bytes_ true        ;#�����ֽ�ģʽ
        [[$ns link $node1 $node2] queue] set wait_ false        ;#���������޼������
        [[$ns link $node1 $node2] queue] set maxthresh_ 20      ;#����ƽ�������������ֵ
}

