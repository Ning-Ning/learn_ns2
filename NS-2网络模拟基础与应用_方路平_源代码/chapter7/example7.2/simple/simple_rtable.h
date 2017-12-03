#ifndef __simple_rtable_h__

#define __simple_rtable_h__

#include <trace.h>

#include <map>

typedef std::map<nsaddr_t, nsaddr_t> rtable_t;

//simple·��Э��ʵ�ֵ�·�ɱ�ܼ򵥣��������洢��Ŀ�ĵ�ַ����һ����ַ��Ϣ��
//ʵ���˻�������ӡ�ɾ��·����Ϣ�Ȼ�������
//������ʹ����C++��׼���map���ݽṹ��������Ա������ʵ�־�ʮ�ּ򵥣�ֻ��Ҫ���û�����map�ӿں�������
class simple_rtable {

   rtable_t rt_;                            //·�ɱ�

   public:

   simple_rtable();                        //���캯��

   void print(Trace*);  
    
   void clear();                           //ɾ��·�ɱ��������Ϣ

   void rm_entry(nsaddr_t);                //ɾ����Ӧ��·�ɱ���

   void add_entry(nsaddr_t, nsaddr_t);     //��·�ɱ������һ��

   nsaddr_t lookup(nsaddr_t);              //���Ҷ�Ӧ�����һ����ַ

   u_int32_t size();                       //����·�ɱ������

};

#endif

