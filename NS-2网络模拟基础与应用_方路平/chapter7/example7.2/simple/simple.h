#ifndef __simple_h__

#define __simple_h__

// �������һЩ��Ҫ��ͷ�ļ�

#include "simple_pkt.h" //���ݰ���ͷ

#include "simple_rtable.h" 

#include <agent.h>  //���������

#include <packet.h> //���ݰ���

#include <trace.h> //�����࣬�����ڸ����ļ����¼����ķ�����

#include <timer-handler.h> //��ʱ�������࣬���������Զ���ļ�ʱ��

#include <random.h> //����࣬���ڲ���α�����

#include <classifier-port.h> //�˿ڷ������࣬������̭���ϲ㴫������ݰ�

#include <mobilenode.h>

#include "arp.h"

#include "ll.h"

#include "mac.h"

#include "ip.h"

#include "delay.h"

#define CURRENT_TIME Scheduler::instance().clock() //������һ�����ڵõ���ǰ����ʱ��ĺ�

                                                                                      //ͨ��һ���������ʵ�����

#define JITTER (Random::uniform()*0.5) //��0-0.5֮��ȥ�������Ϊ�������ݵ��ӳ�ʱ��




class Simple_PktTimer;

//����Simple ��Ķ���
class Simple : public Agent {


//��Ԫ��

friend class Simple_PktTimer;

/* Private members */ //��װ������ĵ�ַ����״̬��·�ɱ��ɱ��Tcl

//����˽�г�Ա�����ͺ���
protected:                                    //�Լ�һ������ָ����������ļ�����

nsaddr_t ra_addr_;      //�����ַ

simple_state state_;    //�ڲ�״̬����

simple_rtable rtable_;  //·�ɱ����simple_rtable����7.2.3����ϸ����

int accesible_var_;     //��OTcl�п��Է��ʵı���

u_int8_t seq_num_;      //���������������������кŸ����������



MobileNode* node_; 
/*PortClassifier�����ָ��dmux_,��Agent�յ������Լ������ݷ��飬����ʹ��dmux_���������
�鴫�ݸ��߲��Ӧ��*/

PortClassifier* dmux_; 
//������һ��Trace�����ָ�룬������ģ������е�·�ɱ���Ϣ��¼�������ļ��С�
Trace* logtarget_; 
//��������һ������simple����Ķ�ʱ������
simple_PktTimer pkt_timer_;

//�����������س�Ա������ֵ

inline nsaddr_t& ra_addr() { return ra_addr_; }

inline simple_state& state() { return state_; }

inline int& accessible_var() { return accesible_var_; }

//ת�������Ա����
void forward_data(Packet*); 
//�����յ�����Ϊsimple����ʱ������simple����ĳ�Ա����
void recv_simple_pkt(Packet*);
//����simple���麯��
void send_simple_pkt();
//���ȶ�ʱ������
void reset_simple_pkt_timer();


public: 


simple(nsaddr_t);   //���캯��

int command(int, const char*const*);

void recv(Packet*, Handler*); //�յ����ݷ���ʱ���������ݷ����Ա����

//void mac_failed(Packet*);


}; 

//Simple_PktTimer��ʱ����Ķ���
class Simple_PktTimer : public TimerHandler {

    public:

    //���캯�������û���Ĺ��캯��
    Simple_PktTimer(simple* agent) : TimerHandler() { 

    agent_ = agent;


    } 

    protected:


    Simple* agent_; 

    virtual void expire(Event* e);


}; 

#endif

