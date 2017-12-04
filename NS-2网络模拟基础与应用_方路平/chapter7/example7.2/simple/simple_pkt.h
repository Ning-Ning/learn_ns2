#ifndef __simple_pkt_h__

#define __simple_pkt_h__

#include <packet.h>

#define HDR_SIMPLE_PKT(p) hdr_simple_pkt::access(p)
//����simpleЭ��ķ���ͷ�ṹ

struct hdr_simple_pkt {

    nsaddr_t pkt_src_; // ���ɴ˷���Ľڵ��ַ

    u_int16_t pkt_len_; // ���鳤�� (in bytes)

    u_int8_t pkt_seq_num_; // �������к�

	//������Ӧ�ı���
    inline nsaddr_t& pkt_src() { return pkt_src_; }

    inline u_int16_t& pkt_len() { return pkt_len_; }

    inline u_int8_t& pkt_seq_num() { return pkt_seq_num_; }
	//��̬����offset_����˷���ͷ�ڷ����е�ƫ����

    static int offset_;

    inline static int& offset() { return offset_; }

   /* ͨ��access��������simpleЭ�����ķ���ͷ���ú�������hdr_simple_pkt�ṹ��ָ��*/
    inline static hdr_simple_pkt* access(const Packet* p) {

           return (hdr_simple_pkt*)p->access(offset_);

    }

};

#endif

