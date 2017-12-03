#include "simple.h"

#include "simple_pkt.h"

#include <random.h>

#include <cmu-trace.h>

#include <iostream>

int HDR_SIMPLE_PKT::offset_;

static class SimpleHeaderClass : public PacketHeaderClass {

       public:

       simpleHeaderClass() : PacketHeaderClass("PacketHeader/Simple", sizeof(HDR_SIMPLE_PKT)) {

              bind_offset(&HDR_SIMPLE_PKT::offset_);

       }

} class_rtProtosimple_hdr;//Ҫ�ѷ���ͷ��OTcl�ӿڰ���������simple.cc�ж���һ����̬��


static class SimpleClass : public TclClass {

       public:

       simpleClass() : TclClass("Agent/Simple") {}

       TclObject* create(int argc, const char*const* argv) {

              assert(argc == 5);
              //����C++Simple��Ķ���
              return (new Simple((nsaddr_t) Address::instance().str2addr(argv[4])));

       }

} class_rtProtosimple;

void Simple_PktTimer::expire(Event* e) {

      agent_->send_simple_pkt();         //һ����ʱ������øú�������Simple����

      agent_->reset_simple_pkt_timer();  //���趨ʱ��

}

Simple::Simple(nsaddr_t id) : Agent(PT_SIMPLE), pkt_timer_(this) {
      /*Agent/Simple���Ա������C++ Simple���Ա�����İ󶨣�������Agent/Simple���б��� accessible_var_Ϊ������*/
      bind_bool("accessible_var_", &accesible_var_);

      ra_addr_ = id;

}

int Simple::command(int argc, const char*const* argv) {

      if (argc == 2) {
             //����simple�����start OTcl����ʵ��
             if (strcasecmp(argv[1], "start") == 0) {

                    pkt_timer_.resched(0.0);

                    return TCL_OK;

             }
             //print_rtable����ʵ�֣���·�ɱ���Ϣд��trace�ļ���
             else if (strcasecmp(argv[1], "print_rtable") == 0) {

                    if (logtarget_ != 0) {

                           sprintf(logtarget_->pt_->buffer(), "P %f _%d_ Routing Table", CURRENT_TIME, ra_addr());

                           logtarget_->pt_->dump();

                           rtable_.print(logtarget_);

                    }

                    else {

                           fprintf(stdout, "%f _%d_ If you want to print this routing table,

                           you must create a trace file in your tcl script", CURRENT_TIME, ra_addr());

                    }

                    return TCL_OK;

             }

      }

       else if (argc == 3) {

      // ��ö�Ӧ dmux���ѷ��鷢�����߲�

             if (strcmp(argv[1], "port-dmux") == 0) {

                    dmux_ = (PortClassifier*)TclObject::lookup(argv[2]);

                    if (dmux_ == 0) {

                           fprintf(stderr, "%s: %s lookup of %s failed\n", __FILE__, argv[1], argv[2]);

                      return TCL_ERROR;

                    }

                    return TCL_OK;

             }

             else if (strcmp(argv[1], "log-target") == 0 || strcmp(argv[1], "tracetarget") == 0) {

                    logtarget_ = (Trace*)TclObject::lookup(argv[2]);

                    if (logtarget_ == 0)

                           return TCL_ERROR;

                     return TCL_OK;

             }

      }

      // Pass the command to the base class

      return Agent::command(argc, argv);

}

void Simple::recv(Packet* p, Handler* h) {

       struct hdr_cmn* ch = HDR_CMN(p); //��ȡָ�򹫹�����ͷ��ָ��

       struct hdr_ip* ih = HDR_IP(p);   //��ȡָ��IP����ͷ��ָ��
	   /*�������Ƿ���Simple�����Լ������ķ��飬������ǣ������Ƿ����·�ɻ�·�����
	   ���ڣ������÷���;����÷����Ǹô����Լ������ķ��飬��IP����ͷ����÷���*/

       if (ih->saddr() == ra_addr()) {

             // ���·�ɷ�����·�������÷���

             if (ch->num_forwards() > 0) {

                    drop(p, DROP_RTR_ROUTE_LOOP);

                    return;

             }

             // ����÷����Ǹô����Լ������ķ��飬��IP����ͷ����÷���

             else if (ch->num_forwards() == 0)

                    ch->size() += IP_HDR_LEN;      //#define IP_HDR_LEN      20   in <ip.h>

      }

       // �����������ΪЭ��Simple�ķ��飬�����recv_simple_pkt()�������д���

      if (ch->ptype() == PT_SIMPLE)

             recv_simple_pkt(p);

      // ���򣬽��Է������ת��(����TTL��ֵΪ0)

      else {

             ih->ttl_--;
			 //��TTL��ֵΪ0ʱ�������÷���
             if (ih->ttl_ == 0) {

                    drop(p, DROP_RTR_TTL);

                    return;

             }
             //����ת���÷���
             forward_data(p);

      }

}

void Simple::recv_simple_pkt(Packet* p) {

       struct hdr_ip* ih = HDR_IP(p); //��ȡָ��IP����ͷ��ָ��
       //��ȡָ��Simple����ͷ��ָ��
       struct hdr_simple_pkt* ph = HDR_SIMPLE_PKT(p);

       //ȷ�����鷢�ͷ��Ķ˿ںͽ��շ��˿ڶ�ΪSimpleЭ��Ķ˿ں�RT_PORT

      assert(ih->sport() == RT_PORT);

      assert(ih->dport() == RT_PORT);

       /* ��Simple����Ĵ�������ֻ�Ǽ򵥵��ͷ���Դ�����Ҫ��Simple��������Ĳ��������������������Ӧ�Ĵ��� */

      Packet::free(p);

}

void Simple::send_simple_pkt() {
      
      //Ϊ�������һ������ռ�
      Packet* p = allocpkt();
      //�ֱ��ȡcommon,IP��Simple����ͷ��ָ��
      struct hdr_cmn* ch = HDR_CMN(p);

      struct hdr_ip* ih = HDR_IP(p);

      struct hdr_simple_pkt* ph = HDR_SIMPLE_PKT(p);
	  //��Simple����ͷ�ĸ������Ը�ֵ���������Ժ������7.2.2

      ph->pkt_src() = ra_addr();

      ph->pkt_len() = 7;

      ph->pkt_seq_num() = seq_num_++;
	  //��common����ͷ�ĸ������Ը�ֵ���������Ժ������6.4.1

      ch->ptype() = PT_SIMPLE;

      ch->direction() = hdr_cmn::DOWN;

      ch->size() = IP_HDR_LEN + ph->pkt_len();

      ch->error() = 0;

      ch->next_hop() = IP_BROADCAST;

      ch->addr_type() = NS_AF_INET;

      //��IP����ͷ�ĸ������Ը�ֵ
      ih->saddr() = ra_addr();

      ih->daddr() = IP_BROADCAST;

      ih->sport() = RT_PORT;

      ih->dport() = RT_PORT;

      ih->ttl() = IP_DEF_TTL;

      Scheduler::instance().schedule(target_, p, JITTER);

}

void Simple::reset_simple_pkt_timer() {
//���ö�ʱ���ĳ�Ա����resched()���ó�ʱʱ��Ϊ5.0s,��ϸ���ݲο�6.3��
       pkt_timer_.resched((double)5.0);

}

void Simple::forward_data(Packet* p) {
      //��ȡcommom��IP����ͷ��ָ��

      struct hdr_cmn* ch = HDR_CMN(p);

      struct hdr_ip* ih = HDR_IP(p);
	  //������ݷ����Ŀ�ĵ�ַ�Ǳ��ڵ㣬��ͨ���˿ڷ����������ϲ�Ӧ�ô���

      if (ch->direction() == hdr_cmn::UP &&

          ((u_int32_t)ih->daddr() == IP_BROADCAST || ih->daddr() == ra_addr())) {

          dmux_->recv(p, 0);

          return;

     }

     else {

         ch->direction() = hdr_cmn::DOWN;

         ch->addr_type() = NS_AF_INET;
		 /*���Ŀ�ĵ�ַ�ǹ㲥��ַ��������commonͷ������һ����ַ��ΪIP_BROADCAST*/

         if ((u_int32_t)ih->daddr() == IP_BROADCAST)

             ch->next_hop() = IP_BROADCAST;
			 //����,��·�ɱ��в�����һ����ַ

         else {
		        /*����simple_rtable�ĳ�Ա����lookup()������һ����ַ��rtable_Ϊsimple_rtable����󣬺�������ϸ����*/

             nsaddr_t next_hop = rtable_.lookup(ih->daddr());

             if (next_hop == IP_BROADCAST) {

                 debug("%f: Agent %d can not forward a packet destined to %d\n",

                     CURRENT_TIME,

                     ra_addr(),

                     ih->daddr());

                 drop(p, DROP_RTR_NO_ROUTE);

                 return;

             }

             else

                 ch->next_hop() = next_hop;

         }

         Scheduler::instance().schedule(target_, p, 0.0);

     }

}

