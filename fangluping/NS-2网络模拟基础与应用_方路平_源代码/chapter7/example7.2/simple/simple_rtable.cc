#include "simple_rtable.h"

#include "ip.h"

simple_rtable::simple_rtable() { }

//print()�����ѽڵ��·�ɱ����������trace�ļ���
void simple_rtable::print(Trace* out) {

       sprintf(out->pt_->buffer(), "P\tdest\tnext");

       out->pt_->dump();

      for (rtable_t::iterator it = rt_.begin(); it != rt_.end(); it++) {

             sprintf(out->pt_->buffer(), "P\t%d\t%d", (*it).first, (*it).second);

             out->pt_->dump();

      }

}

//clear()�����Ƴ�·�ɱ��������Ϣ
void simple_rtable::clear() {

       rt_.clear();

}

//rm_entry()������һ��Ŀ���ַΪ������ɾ����Ӧ��·�ɱ���
void simple_rtable::rm_entry(nsaddr_t dest) {

       rt_.erase(dest);

}

//add_entry()������Ŀ���ַ����һ����ַΪ������·�ɱ������һ��
void simple_rtable::add_entry(nsaddr_t dest, nsaddr_t next) {

       rt_[dest] = next;

}

//lookup()������Ŀ���ַΪ���������ض�Ӧ�����һ����ַ����������ڶ�Ӧ
//��,�򷵻�IP_BROADCAST��
nsaddr_t simple_rtable::lookup(nsaddr_t dest) {

       rtable_t::iterator it = rt_.find(dest);

       if (it == rt_.end())

              return IP_BROADCAST;

       else

              return (*it).second;

}

//size()��������·�ɱ�����
u_int32_t simple_rtable::size() {

       return rt_.size();

}

